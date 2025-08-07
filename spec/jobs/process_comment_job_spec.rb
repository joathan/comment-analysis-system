# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessCommentJob, type: :job do
  let(:comment) { create(:comment, body: 'Hello world', state: :new) }
  let(:translated_text) { 'Olá mundo' }
  let(:service_instance) { instance_double(TranslationService) }

  before do
    allow(TranslationService).to receive(:new).and_return(service_instance)
    allow(service_instance).to receive(:translate).with(comment.body, target: 'pt-BR').and_return(translated_text)
  end

  it 'translates and approves the comment when keyword matches' do
    allow(Keyword).to receive(:approved?).with(translated_text).and_return(true)

    described_class.perform_now(comment.id)

    comment.reload

    expect(comment.body).to eq(translated_text)
    expect(comment).to be_approved
  end

  it 'translates and rejects the comment when keyword does not match' do
    allow(Keyword).to receive(:approved?).with(translated_text).and_return(false)

    described_class.perform_now(comment.id)

    comment.reload

    expect(comment.body).to eq(translated_text)
    expect(comment).to be_rejected
  end

  it 'does nothing if the comment is already processing' do
    comment.update!(state: :processing)

    expect(service_instance).not_to receive(:translate)
    expect(Keyword).not_to receive(:approved?)

    described_class.perform_now(comment.id)

    expect(comment.reload.state).to eq('processing')
  end

  it 'does nothing if the comment is already approved' do
    comment.update!(state: :approved)

    expect(service_instance).not_to receive(:translate)
    expect(Keyword).not_to receive(:approved?)

    described_class.perform_now(comment.id)

    expect(comment.reload.state).to eq('approved')
  end

  it 'does nothing if the comment is already rejected' do
    comment.update!(state: :rejected)

    expect(service_instance).not_to receive(:translate)
    expect(Keyword).not_to receive(:approved?)

    described_class.perform_now(comment.id)

    expect(comment.reload.state).to eq('rejected')
  end

  it 'uses a database lock during processing' do
    expect_any_instance_of(Comment).to receive(:with_lock).and_call_original

    described_class.perform_now(comment.id)
  end

  it 'does nothing if comment is not found' do
    non_existent_id = Comment.maximum(:id).to_i + 1

    expect { described_class.perform_now(non_existent_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

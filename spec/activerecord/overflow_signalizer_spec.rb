require 'spec_helper'

RSpec.describe ActiveRecord::OverflowSignalizer do
  it 'has a version number' do
    expect(ActiveRecord::OverflowSignalizer::VERSION).not_to be nil
  end

  describe '#analise!' do
    context 'signalize to logger' do
      let!(:logger) { double(:logger, warn: true) }

      subject { described_class.new(logger: logger) }

      it 'doesn`t log anything' do
        expect(logger).not_to receive(:warn)
        subject.analise!
      end
    end
  end
end

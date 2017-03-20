require 'spec_helper'

RSpec.describe ActiveRecord::OverflowSignalizer do
  it 'has a version number' do
    expect(ActiveRecord::OverflowSignalizer::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end

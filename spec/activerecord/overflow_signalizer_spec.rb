require 'spec_helper'

RSpec.describe ActiveRecord::OverflowSignalizer do
  it 'has a version number' do
    expect(ActiveRecord::OverflowSignalizer::VERSION).not_to be nil
  end

  describe '#analyse!' do
    context 'raise exception' do
      subject { described_class.new(models: [TestIntModel], days_count: 10) }

      context 'empty table' do
        it { expect { subject.analyse! }.not_to raise_error }
      end

      context 'not empty table' do
        let(:max_int) { 2_147_483_647 }
        let(:day) { 24 * 60 * 60 }
        let(:today) { Time.now }

        context 'overflow far' do
          before do
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it { expect { subject.analyse! }.not_to raise_error }
        end

        context 'overflow soon' do
          before do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH #{max_int - 16};})
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it { expect { subject.analyse! }.to raise_error(described_class::Overflow) }
        end

        context 'overflowed' do
          before do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH #{max_int - 6};})
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it { expect { subject.analyse! }.to raise_error(described_class::Overflow) }
        end
      end
    end
  end

  describe '#analyse' do
    context 'signalize to logger' do
      let!(:logger) { double(:logger, warn: true) }

      subject { described_class.new(logger: logger, models: [TestIntModel], days_count: 10) }

      context 'empty table' do
        it 'doesnt log anything' do
          expect(logger).not_to receive(:warn)
          subject.analyse
        end
      end

      context 'not empty table' do
        let(:max_int) { 2_147_483_647 }
        let(:day) { 24 * 60 * 60 }
        let(:today) { Time.now }

        context 'overflow far' do
          before do
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it 'doesnt log anything' do
            expect(logger).not_to receive(:warn)
            subject.analyse
          end
        end

        context 'overflow soon' do
          before do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH #{max_int - 16};})
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it 'log about owerflow' do
            expect(logger).to receive(:warn)
              .with("Primary key in table #{TestIntModel.table_name} will overflow soon! #{TestIntModel.last.id} from #{max_int}")
            subject.analyse
          end
        end

        context 'overflowed' do
          before do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH #{max_int - 6};})
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it 'log about owerflow' do
            expect(logger).to receive(:warn)
              .with("Primary key in table #{TestIntModel.table_name} overflowed! #{TestIntModel.last.id} from #{max_int}")
            subject.analyse
          end
        end
      end
    end

    context 'custom signalizer' do
      let!(:signalizer) { double(:signalizer, signalize: true) }

      subject { described_class.new(signalizer: signalizer, models: [TestIntModel], days_count: 10) }

      context 'empty table' do
        it 'doesnt log anything' do
          expect(signalizer).not_to receive(:signalize)
          subject.analyse
        end
      end

      context 'not empty table' do
        let(:max_int) { 2_147_483_647 }
        let(:day) { 24 * 60 * 60 }
        let(:today) { Time.now }

        context 'overflow far' do
          before do
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it 'doesnt log anything' do
            expect(signalizer).not_to receive(:signalize)
            subject.analyse
          end
        end

        context 'overflow soon' do
          before do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH #{max_int - 16};})
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it 'log about owerflow' do
            expect(signalizer).to receive(:signalize)
              .with("Primary key in table #{TestIntModel.table_name} will overflow soon! #{TestIntModel.last.id} from #{max_int}")
            subject.analyse
          end
        end

        context 'overflowed' do
          before do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH #{max_int - 6};})
            (1..7).each do |t|
              TestIntModel.create!(created_at: today - day * t, updated_at: today - day * t)
            end
          end

          after do
            TestIntModel.connection.execute(%Q{ALTER SEQUENCE "int_test_id_seq" RESTART WITH 1;})
            TestIntModel.destroy_all
          end

          it 'log about owerflow' do
            expect(signalizer).to receive(:signalize)
              .with("Primary key in table #{TestIntModel.table_name} overflowed! #{TestIntModel.last.id} from #{max_int}")
            subject.analyse
          end
        end
      end
    end
  end
end

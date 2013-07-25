require 'spec_helper'

describe Bourgeois::Presenter do
  let(:user) { User.new first_name: 'Patrick', last_name: 'Bourgeois' }
  let(:view) { ActionView::Base.new }
  let(:presenter) { UserPresenter.new(user, view) }

  describe :DelegatedMethods do
    before do
      class UserPresenter < Bourgeois::Presenter
        def formatted_name
          "#{first_name} #{last_name}".strip
        end
      end

      class User < OpenStruct
      end
    end

    it { expect(presenter.formatted_name).to eql 'Patrick Bourgeois' }
    it { expect(presenter.first_name).to eql 'Patrick' }
    it { expect(presenter.last_name).to eql 'Bourgeois' }
  end

  describe :InstanceMethods do
    describe :initialize do
      before do
        class UserPresenter < Bourgeois::Presenter; end
        class User < OpenStruct; end
      end

      it { expect{ UserPresenter.new(user) }.to_not raise_error }
    end

    describe :view do
      context 'with present view' do
        before do
          class UserPresenter < Bourgeois::Presenter
            def local_name
              view.t('users.attributes.local_name')
            end
          end

          class ActionView::Base
            def t(*args)
              "Fancy translated string from #{args.join(', ')}"
            end
          end

          class User < OpenStruct; end
        end

        it { expect(presenter.local_name).to eql 'Fancy translated string from users.attributes.local_name' }
      end

      context 'with blank view' do
        before do
          class UserPresenter < Bourgeois::Presenter; end
          class User < OpenStruct; end
        end

        let(:presenter) { UserPresenter.new(user) }

        it { expect(presenter.instance_variable_get(:@view)).to be_nil }
      end
    end

    describe :inspect do
      before do
        class UserPresenter < Bourgeois::Presenter; end
        class User < OpenStruct; end
      end
      let(:user) { User.new foo: 'bar' }

      it { expect(presenter.inspect).to eql '#<UserPresenter object=#<User foo="bar">>' }
    end
  end

  describe :ClassMethods do
    describe :kind_of? do
      before do
        class UserPresenter < Bourgeois::Presenter; end
        class User < OpenStruct; end
      end

      it { expect(presenter).to be_kind_of(User) }
    end

    describe :model_name do
      before do
        class UserPresenter < Bourgeois::Presenter; end
        class User < OpenStruct; end

        User.should_receive(:model_name).and_return(:foo)
      end

      it { expect(UserPresenter.model_name).to eql :foo }
    end

    describe :human_attribute_name do
      before do
        class UserPresenter < Bourgeois::Presenter; end
        class User < OpenStruct; end

        User.should_receive(:human_attribute_name).and_return(:foo)
      end

      it { expect(UserPresenter.human_attribute_name).to eql :foo }
    end
  end
end

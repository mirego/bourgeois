require 'spec_helper'

describe Bourgeois::Presenter do
  let(:user) { User.new first_name: 'Patrick', last_name: 'Bourgeois', birthdate: '1962-06-16' }
  let(:view) { ActionView::Base.new }
  let(:presenter) { UserPresenter.new(user, view) }

  describe :DelegatedMethods do
    before do
      class UserPresenter < Bourgeois::Presenter
        def formatted_name
          "#{first_name} #{last_name}".strip
        end

        def birthdate
          super.presence || 'Unknown'
        end
      end

      class User < OpenStruct
      end
    end

    it { expect(presenter.formatted_name).to eql 'Patrick Bourgeois' }
    it { expect(presenter.first_name).to eql 'Patrick' }
    it { expect(presenter.last_name).to eql 'Bourgeois' }
    it { expect(presenter.birthdate).to eql '1962-06-16' }
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

            def first_name_in_bold
              view.content_tag :strong, first_name
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
        it { expect(presenter.first_name_in_bold).to eql '<strong>Patrick</strong>' }
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

    describe :object do
      before do
        class UserPresenter < Bourgeois::Presenter
          def birthdate
            object.birthdate.gsub(/-/, '/')
          end
        end

        class User < OpenStruct; end
      end

      it { expect(presenter.birthdate).to eql '1962/06/16' }
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
    describe :helper do
      before do
        class UserPresenter < Bourgeois::Presenter
          # Our helpers
          helper :with_profile, if: -> { profile.present? }
          helper :without_name, unless: -> { full_name.present? }
          helper :never, unless: -> { true }, if: -> { true }
          helper :also_never, unless: -> { false }, if: -> { false }
          helper :with_something

          # We need a method to test that our block is executed
          attr_reader :foo
        end
      end

      context 'with matching if condition' do
        let(:user) { User.new profile: 'Je suis Patrick.' }

        specify do
          presenter.should_receive(:foo).once

          presenter.with_profile do
            presenter.foo
          end
        end
      end

      context 'with non-matching if condition' do
        let(:user) { User.new profile: nil }

        specify do
          presenter.should_receive(:foo).never

          presenter.with_profile do
            presenter.foo
          end
        end
      end

      context 'with matching unless condition' do
        let(:user) { User.new full_name: nil }

        specify do
          presenter.should_receive(:foo).once

          presenter.without_name do
            presenter.foo
          end
        end
      end

      context 'with non-matching unless condition' do
        let(:user) { User.new full_name: 'Patrick Bourgeois' }

        specify do
          presenter.should_receive(:foo).never

          presenter.without_name do
            presenter.foo
          end
        end
      end

      context 'with helper without if nor unless' do
        let(:user) { User.new }

        specify do
          presenter.should_receive(:foo).once

          presenter.with_something do
            presenter.foo
          end
        end
      end

      context 'with matching if and non-matching unless conditions' do
        let(:user) { User.new }

        specify do
          presenter.should_receive(:foo).never

          presenter.never do
            presenter.foo
          end
        end
      end

      context 'with non-matching if and matching unless conditions' do
        let(:user) { User.new }

        specify do
          presenter.should_receive(:foo).never

          presenter.also_never do
            presenter.foo
          end
        end
      end
    end

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

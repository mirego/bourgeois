require 'spec_helper'

describe Bourgeois::Presenter do
  let(:user) { User.new first_name: 'Patrick', last_name: 'Bourgeois', birthdate: '1962-06-16' }
  let(:view) { ActionView::Base.new }
  let(:presenter) { UserPresenter.new(user, view) }

  describe :DelegatedMethods do
    before do
      class UserPresenter
        include Bourgeois::Presenter

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
    it { expect { presenter.foo }.to raise_error(NoMethodError) }
  end

  describe :InstanceMethods do
    describe :initialize do
      before do
        class UserPresenter
          include Bourgeois::Presenter
        end

        class User < OpenStruct; end
      end

      it { expect{ UserPresenter.new(user) }.to_not raise_error }
    end

    describe :view do
      context 'with present view' do
        before do
          class UserPresenter
            include Bourgeois::Presenter

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
          class UserPresenter
            include Bourgeois::Presenter
          end

          class User < OpenStruct; end
        end

        let(:presenter) { UserPresenter.new(user) }

        it { expect(presenter.instance_variable_get(:@view)).to be_nil }
      end
    end

    describe :object do
      before do
        class UserPresenter
          include Bourgeois::Presenter

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
        class UserPresenter
          include Bourgeois::Presenter
        end

        class User < OpenStruct; end
      end
      let(:user) { User.new foo: 'bar' }

      it { expect(presenter.inspect).to eql '#<UserPresenter object=#<User foo="bar">>' }
    end
  end

  describe :ClassMethods do
    describe :helper do
      before do
        class UserPresenter
          include Bourgeois::Presenter

          # We need a method to test that our block is executed
          attr_reader :foo
        end
      end

      let(:call_it!) do
        presenter.send(helper) do
          presenter.foo
        end
      end

      context 'with helper using only a if condition' do
        before do
          class UserPresenter
            helper :with_profile, if: -> { profile.present? }
          end
        end

        context 'with matching if condition' do
          let(:user) { User.new profile: 'Je suis Patrick.' }
          let(:helper) { :with_profile }

          specify do
            presenter.should_receive(:foo).once
            call_it!
          end
        end

        context 'with non-matching if condition' do
          let(:user) { User.new profile: nil }
          let(:helper) { :with_profile }

          specify do
            presenter.should_receive(:foo).never
            call_it!
          end
        end
      end

      context 'with helper using only an unless condition' do
        let(:helper) { :without_name }
        before do
          class UserPresenter
            helper :without_name, unless: -> { full_name.present? }
          end
        end

        context 'with matching unless condition' do
          let(:user) { User.new full_name: nil }

          specify do
            presenter.should_receive(:foo).once
            call_it!
          end
        end

        context 'with non-matching unless condition' do
          let(:user) { User.new full_name: 'Patrick Bourgeois' }

          specify do
            presenter.should_receive(:foo).never
            call_it!
          end
        end
      end

      context 'with helper without if nor unless' do
        let(:user) { User.new }
        let(:helper) { :with_something }
        before do
          class UserPresenter
            helper :with_something
          end
        end

        specify do
          presenter.should_receive(:foo).once
          call_it!
        end
      end

      context 'with helper using both matching and unless conditions' do
        let(:helper) { :sometimes }
        before do
          class UserPresenter
            helper :sometimes, if: -> { profile.present? }, unless: -> { full_name.present? }
          end
        end

        context 'with matching if and non-matching unless condition' do
          let(:user) { User.new(profile: true, full_name: 'Patrick Bourgeois') }
          specify do
            presenter.should_receive(:foo).never
            call_it!
          end
        end

        context 'with non-matching if and non-matching unless condition' do
          let(:user) { User.new(profile: false, full_name: 'Patrick Bourgeois') }
          specify do
            presenter.should_receive(:foo).never
            call_it!
          end
        end

        context 'with matching if and matching unless condition' do
          let(:user) { User.new(profile: true, full_name: nil) }
          specify do
            presenter.should_receive(:foo).once
            call_it!
          end
        end

        context 'with non-matching if and matching unless condition' do
          let(:user) { User.new(profile: false, full_name: 'Patrick Bourgeois') }
          specify do
            presenter.should_receive(:foo).never
            call_it!
          end
        end
      end
    end

    describe :kind_of? do
      before do
        class UserPresenter
          include Bourgeois::Presenter
        end

        class User < OpenStruct; end
      end

      it { expect(presenter).to be_kind_of(User) }
    end

    describe :model_name do
      before do
        class UserPresenter
          include Bourgeois::Presenter
        end

        class User < OpenStruct; end

        User.should_receive(:model_name).and_return(:foo)
      end

      it { expect(UserPresenter.model_name).to eql :foo }
    end

    describe :human_attribute_name do
      before do
        class UserPresenter
          include Bourgeois::Presenter
        end

        class User < OpenStruct; end

        User.should_receive(:human_attribute_name).and_return(:foo)
      end

      it { expect(UserPresenter.human_attribute_name).to eql :foo }
    end
  end
end

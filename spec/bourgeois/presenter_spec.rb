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

      it { expect { UserPresenter.new(user) }.to_not raise_error }
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

    describe :present do
      let(:view) { ActionView::Base.new }

      before do
        class UserPresenter < Bourgeois::Presenter
          def formatted_name
            "#{first_name} #{last_name}".strip
          end
        end

        class User < OpenStruct; end
      end

      context 'on a Nil object' do
        context 'without a block' do
          it { expect { view.present(nil) }.not_to raise_error }
        end

        context 'with a block' do
          before { UserPresenter.any_instance.should_receive(:formatted_name).never }

          specify do
            expect do
              view.present(nil) { |obj| obj.formatted_name }
            end.not_to raise_error
          end
        end
      end

      context 'on a single resource' do
        let(:user) { User.new first_name: 'Patrick', last_name: 'Bourgeois' }

        context 'without a block' do
          it { expect(view.present(user).formatted_name).to eql 'Patrick Bourgeois' }
        end

        context 'with a block' do
          specify do
            view.present(user) do |u|
              expect(u.formatted_name).to eql 'Patrick Bourgeois'
            end
          end
        end
      end

      context 'on a single already-presented resource' do
        let(:user) { User.new first_name: 'Patrick', last_name: 'Bourgeois' }
        let(:presenter) { UserPresenter.new(user) }

        context 'without a block' do
          it { expect(view.present(presenter).formatted_name).to eql 'Patrick Bourgeois' }
        end

        context 'with a block' do
          specify do
            view.present(presenter) do |u|
              expect(u.formatted_name).to eql 'Patrick Bourgeois'
            end
          end
        end
      end

      context 'on a collection of resources' do
        let(:user1) { User.new first_name: 'Patrick', last_name: 'Bourgeois' }
        let(:user2) { User.new first_name: 'Francois', last_name: 'Jean' }
        let(:user3) { User.new first_name: 'Alain', last_name: 'Lapointe' }
        let(:users) { [user1, user2, user3] }

        specify do
          output = []
          view.present(users) { |u| output << u.formatted_name }

          expect(output).to eql ['Patrick Bourgeois', 'Francois Jean', 'Alain Lapointe']
        end
      end

      context 'on a collection of already-presented resources' do
        let(:user1) { User.new first_name: 'Patrick', last_name: 'Bourgeois' }
        let(:user2) { User.new first_name: 'Francois', last_name: 'Jean' }
        let(:user3) { User.new first_name: 'Alain', last_name: 'Lapointe' }
        let(:users) { [UserPresenter.new(user1), UserPresenter.new(user2), UserPresenter.new(user3)] }

        specify do
          output = []
          view.present(users) { |u| output << u.formatted_name }

          expect(output).to eql ['Patrick Bourgeois', 'Francois Jean', 'Alain Lapointe']
        end
      end

      context 'on a resource without a defined presenter class' do
        before do
          class Project < OpenStruct; end
        end

        let(:project) { Project.new name: 'Les B.B.' }
        it { expect { view.present(project) }.to raise_error(Bourgeois::UnknownPresenter, 'unknown presenter class ProjectPresenter') }
      end

      context 'on a resource with a custom presenter class' do
        before do
          class Article < OpenStruct; end
          class CustomArticlePresenter < Bourgeois::Presenter
            def name
              super.upcase
            end
          end
        end

        let(:article) { Article.new name: 'Les B.B.' }
        let(:presented_article) { view.present(article, CustomArticlePresenter) }

        it { expect { presented_article }.not_to raise_error }
        it { expect(presented_article.name).to eql 'LES B.B.' }
      end

      context 'on a Struct-based resource' do
        before do
          class Band < Struct.new(:name)
          end

          class BandPresenter < Bourgeois::Presenter
            def name
              super.upcase
            end
          end
        end

        let(:band) { Band.new('Les B.B.') }
        let(:presented_band) { view.present(band) }

        it { expect(presented_band.name).to eql 'LES B.B.' }
      end

      context 'on a collection of resources with a custom presenter class' do
        before do
          class Article < OpenStruct; end
          class CustomArticlePresenter < Bourgeois::Presenter
            def name
              super.upcase
            end
          end
        end

        let(:articles) { [Article.new(name: 'Les B.B.'), Article.new(name: 'Rock et Belles Oreilles')] }

        specify do
          output = []
          view.present(articles, CustomArticlePresenter) { |u| output << u.name }

          expect(output).to eql ['LES B.B.', 'ROCK ET BELLES OREILLES']
        end
      end
    end
  end
end

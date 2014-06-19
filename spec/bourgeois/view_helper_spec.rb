require 'spec_helper'

describe Bourgeois::ViewHelper do
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

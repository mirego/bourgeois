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

    context 'on a resource without a defined presenter class' do
      before do
        class Project < OpenStruct; end
      end

      let(:project) { Project.new name: 'Les B.B.' }
      it { expect { view.present(project) }.to raise_error(Bourgeois::UnknownPresenter, 'unknown presenter class ProjectPresenter') }
    end
  end
end

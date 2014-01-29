<p align="center">
  <a href="https://github.com/mirego/bourgeois">
    <img src="http://i.imgur.com/Z8ja8Wz.png" alt="Bourgeois" />
  </a>
  <br />
  Bourgeois is a Ruby library that makes using presenters a very simple thing.
  <br /><br />
  <a href="https://rubygems.org/gems/bourgeois"><img src="https://badge.fury.io/rb/bourgeois.png" /></a>
  <a href="https://codeclimate.com/github/mirego/bourgeois"><img src="https://codeclimate.com/github/mirego/bourgeois.png" /></a>
  <a href='https://coveralls.io/r/mirego/bourgeois?branch=master'><img src='https://coveralls.io/repos/mirego/bourgeois/badge.png?branch=master' /></a>
  <a href='https://gemnasium.com/mirego/bourgeois'><img src="https://gemnasium.com/mirego/bourgeois.png" /></a>
  <a href="https://travis-ci.org/mirego/bourgeois"><img src="https://travis-ci.org/mirego/bourgeois.png?branch=master" /></a>
</p>

---

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'bourgeois'
```

And then execute:

```bash
$ bundle
```

## Usage

Create an `app/presenters` directory and put some presenters in it:

```ruby
# app/presenters/user_presenter.rb

class UserPresenter < Bourgeois::Presenter
  def formatted_name
    "#{first_name} #{last_name}".strip
  end
end
```

Then, you can use the `present` helper in your views to wrap `ActiveModel` (and `ActiveRecord`) objects around a presenter:

```erb
<% present User.first do |user| %>
  <p>This is <%= user.formatted_name %></p>
<% end %>
```

Methods that aren’t in the presenter (`first_name` and `last_name`) are delegated to the presented object. You can also use the `view` method in the presenter to get the original view it was called in:

```ruby
# app/presenters/user_presenter.rb

class UserPresenter < Bourgeois::Presenter
  def birthdate
    # To get the original `birthdate` value, you can either use `super` or `object.birthdate`
    super.presence || view.content_tag(:em, 'Unknown')
  end
end
```

### Custom block helpers

You can use the simple `helper` DSL to define block helpers that will be executed if certain
conditions are matched.

```ruby
class UserPresenter < Bourgeois::Presenter
  helper :with_profile, if: -> { profile.present? && profile.public? }
end

User.first.profile = Profile.create(public: true, title: 'Foo', description: 'Bar')
```

```erb
<% present User.first do |user| %>
  <h1><%= user.full_name %></h1>
  <% user.with_profile do %>
    <div class="profile">
      <h2><%= user.profile.title %></h2>
      <%= simple_format(user.profile.description) %>
    </div>
  <% end %>
<% end %>
```

## Inspiration

Bourgeois was inspired by some code [@rafBM](https://twitter.com/rafBM) wrote for [his OpenCode talk](https://github.com/rafBM/opencode12-rails) on May 28th, 2013.

## License

`Bourgeois` is © 2013 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/bourgeois/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're team of [talented people](http://life.mirego.com) who imagine and build beautiful web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.

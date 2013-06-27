# Bourgeois

Bourgeois is a Ruby library that makes using presenters a very simple thing.

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
<% present(@user) do |user| %>
  <p>This is <%= user.formatted_name %></p>
<% end %>
```

Methods that aren’t in the presenter (`first_name` and `last_name`) are delegated to the presented object. You can also use the `view` method in the presenter to get the original view it was called in.

## Inspiration

Bourgeois was inspired by some code [@rafBM](https://twitter.com/rafBM) wrote for [his OpenCode talk](https://github.com/rafBM/opencode12-rails) on May 28th, 2013.

## License

`Bourgeois` is © 2013 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/bourgeois/blob/master/LICENSE.md) file.

## About Mirego

Mirego is a team of passionate people who believe that work is a place where you can innovate and have fun.
We proudly built mobile applications for [iPhone](http://mirego.com/en/iphone-app-development/ "iPhone application development"), [iPad](http://mirego.com/en/ipad-app-development/ "iPad application development"), [Android](http://mirego.com/en/android-app-development/ "Android application development"), [Blackberry](http://mirego.com/en/blackberry-app-development/ "Blackberry application development"), [Windows Phone](http://mirego.com/en/windows-phone-app-development/ "Windows Phone application development") and [Windows 8](http://mirego.com/en/windows-8-app-development/ "Windows 8 application development").

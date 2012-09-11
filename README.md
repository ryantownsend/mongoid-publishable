# Mongoid::Publishable

Ever wanted to allow your users to create something (or somethings) before authenticating. For example, you might want to let them write a review, before you ask them to login and publish it. This is what Mongoid::Publishable handles.

## Installation

Add this line to your application's Gemfile:

    gem "mongoid-publishable"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid-publishable

## Usage

Include the module in any models you want to be publishable:

```ruby
class Review
  include Mongoid::Document
  include Mongoid::Publishable
  # ...
end
```

It will use the `user_id` column by default, but you can override that by using `publisher_column`. It also assumes you're using the `id` attribute of the publisher, again you can override it using `publisher_foreign_key`, here's an example:

```ruby
class ChatMessage
  include Mongoid::Document
  include Mongoid::Publishable
  
  belongs_to :author
 
  publisher_column :author_id
  publisher_foreign_key :username
  # ...
end
```

In your controllers, or anywhere you save the objects, you can swap out your `save` calls for `persist_and_publish!` calls, this method accepts an optional user. If none is passed, or the object that you do pass is nil, it'll raise an exception, so you can handle your authentication there:

```ruby
class ReviewsController < ApplicationController
  include Mongoid::Publishable::Queuing

  def create
    # create the review
    @review = Review.new(params[:review])
    # if persisted and published
    if @review.persist_and_publish!(current_user)
      # redirect as normal
      redirect_to @review, notice: "Review created!"
    # validation failed
    else
      render :new
    end
  # persisted, but publishing failed
  rescue Mongoid::Publishable::UnpublishedError => exception
    # the error actually contains the object
    publishing_queue << exception.model
    # send the user to the login page
    redirect_to new_user_session_path
  end
end
```

An alternative without the exception handling would be:

```ruby
class ReviewsController < ApplicationController
  include Mongoid::Publishable::Queuing

  def create
    # create the review
    @review = Review.new(params[:review])
    @review.publish_via(current_user)
    # if persisted and published
    if @review.save && @review.published?
      # redirect as normal
      redirect_to @review, notice: "Review created!"
    # persisted, but publishing failed
    elsif @review.persisted?
      # the error actually contains the object
      publishing_queue << @review
      # send the user to the login page
      redirect_to new_user_session_path
    # validation failed
    else
      render :new
    end
  end
end
```
   
The advantage to the former style (using exceptions) is that you can handle them globally in your ApplicationController using this code:

```ruby
class ApplicationController < ActionController::Base
  include Mongoid::Publishable::Queuing
  
  rescue_from Mongoid::Publishable::UnpublishedError, with: :authenticate_to_publish
  
  protected
  def authenticate_to_publish(exception)
    # add the object on to the queue
    publishing_queue << exception.model
    # send the user to the login page
    redirect_to new_user_session_path
  end
end
```

The publishing queue is stored in the user's session. After authentication, you'll want to call `publish_via` on the queue, which will then publish all the objects it contains. Here's an example:

```ruby
class UserSessionsController < ApplicationController
  def create
    @user = User.authenticate(params[:user])
    if @user
      
      # this is the key line:
      publishing_queue.publish_via(@user)
      
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Login successful!"
    else
      render :new
    end
  end
  
  # ...
end
```

Models are also provided with an `after_publish` callback that can be used like any other ActiveModel-style callback.

```ruby
class Review
  include Mongoid::Document
  include Mongoid::Publishable
  
  # it accepts a symbol referencing a method
  after_publish :notify_item_owner
  # it also accepts a block
  after_publish do
    puts "Mongoid::Publishable and it's creator are awesome!"
  end
  
  private
  def notify_item_owner
    # do something
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

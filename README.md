# Ruby ObjectTracker

Track class and instance methods, including arguments and definition source. You can extend a class to track calls to itself and it's 
instances, or extend instances directly. This can be helpful for debugging by providing info on what methods are being called on your object

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'object_tracker'
```

Or try it out by cloning the repo and running:

```bash
irb -I ./lib -r object_tracker
```

## Usage

```ruby
class MyKlass
  extend ObjectTracker

  def fetch(name)
    "Fetch the ball, #{name}!"
  end
end
```

Track a single method:

```ruby
MyKlass.track :fetch
```

Or track all methods:

```ruby
MyKlass.track_all!
```

Or track an instance:

```ruby
obj = MyKlass.new.extend ObjectTracker
obj.track_all!
```

## Example

Tracking a Sequel::Model object:

```bash
>> Website.extend ObjectTracker
=> Website
>> Website.track_all!
   * called "#inspect" [sequel-4.21.0/lib/sequel/model/base.rb:1368]
=> Website
>> Website.count
   * called ".count" [sequel-4.21.0/lib/sequel/model/plugins.rb:28]
   * called ".dataset" [sequel-4.21.0/lib/sequel/model/base.rb:157]
I, [2015-07-07T19:15:57.897695 #39091]  INFO -- : (0.000794s) SELECT count(*) AS "count" FROM "websites" LIMIT 1
=> 0
>> Website.first
   * called ".first" [sequel-4.21.0/lib/sequel/model/base.rb:459]
   * called ".dataset" [sequel-4.21.0/lib/sequel/model/base.rb:157]
I, [2015-07-07T19:16:01.016948 #39091]  INFO -- : (0.001045s) SELECT * FROM "websites" LIMIT 1
=> nil
>> Website.create(user_id: 101, url: 'http://cnn.com')
   * called ".create" with {:user_id=>101, :url=>"http://cnn.com"} [sequel-4.21.0/lib/sequel/model/base.rb:147]
   * called ".new" with {:user_id=>101, :url=>"http://cnn.com"} [RUBY CORE]
   * called "#set" with {:user_id=>101, :url=>"http://cnn.com"} [sequel-4.21.0/lib/sequel/model/base.rb:1572]
   * called ".setter_methods" with default [sequel-4.21.0/lib/sequel/model/base.rb:732]
   * called "#model" [RUBY CORE]
   * called ".setter_methods" [sequel-4.21.0/lib/sequel/model/base.rb:732]
   * called ".allowed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:13]
   * called ".instance_methods" [RUBY CORE]
   * called "#primary_key" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called ".restrict_primary_key?" [sequel-4.21.0/lib/sequel/model/base.rb:646]
   * called "#primary_key" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#strict_param_setting" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#strict_param_setting" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#set_column_value" with user_id=, 101 [RUBY CORE]
   * called "#user_id=" with 101 [sequel-4.21.0/lib/sequel/model/base.rb:858]
   * called "#typecast_on_assignment" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#typecast_on_assignment" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#raise_on_typecast_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#raise_on_typecast_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#model" [RUBY CORE]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#new?" [sequel-4.21.0/lib/sequel/model/base.rb:1454]
   * called "#model" [RUBY CORE]
   * called ".autoreloading_associations" [sequel-4.21.0/lib/sequel/model/associations.rb:1417]
   * called "#changed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:1252]
   * called "#set_column_value" with url=, http://cnn.com [RUBY CORE]
   * called "#url=" with http://cnn.com [sequel-4.21.0/lib/sequel/model/base.rb:858]
   * called "#typecast_on_assignment" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#raise_on_typecast_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#model" [RUBY CORE]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#new?" [sequel-4.21.0/lib/sequel/model/base.rb:1454]
   * called "#model" [RUBY CORE]
   * called ".autoreloading_associations" [sequel-4.21.0/lib/sequel/model/associations.rb:1417]
   * called "#changed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:1252]
   * called "#changed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:1252]
   * called "#save" [sequel-4.21.0/lib/sequel/model/base.rb:1539]
   * called "#frozen?" [RUBY CORE]
   * called "#new?" [sequel-4.21.0/lib/sequel/model/base.rb:1454]
   * called "#model" [RUBY CORE]
   * called ".create_timestamp_field" [sequel-4.21.0/lib/sequel/plugins/timestamps.rb:40]
   * called "#respond_to?" with created_at [RUBY CORE]
   * called "#respond_to?" with created_at= [RUBY CORE]
   * called "#model" [RUBY CORE]
   * called ".create_timestamp_overwrite?" [sequel-4.21.0/lib/sequel/plugins/timestamps.rb:46]
   * called "#get_column_value" with created_at [RUBY CORE]
   * called "#created_at" [sequel-4.21.0/lib/sequel/model/base.rb:857]
   * called "#model" [RUBY CORE]
   * called ".dataset" [sequel-4.21.0/lib/sequel/model/base.rb:157]
   * called "#set_column_value" with created_at=, 2015-07-07 19:16:24 -0700 [RUBY CORE]
   * called "#created_at=" with 2015-07-07 19:16:24 -0700 [sequel-4.21.0/lib/sequel/model/base.rb:858]
   * called "#typecast_on_assignment" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#raise_on_typecast_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#model" [RUBY CORE]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#new?" [sequel-4.21.0/lib/sequel/model/base.rb:1454]
   * called "#model" [RUBY CORE]
   * called ".autoreloading_associations" [sequel-4.21.0/lib/sequel/model/associations.rb:1417]
   * called "#changed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:1252]
   * called "#model" [RUBY CORE]
   * called ".set_update_timestamp_on_create?" [sequel-4.21.0/lib/sequel/plugins/timestamps.rb:54]
   * called "#model" [RUBY CORE]
   * called ".update_timestamp_field" [sequel-4.21.0/lib/sequel/plugins/timestamps.rb:43]
   * called "#respond_to?" with updated_at= [RUBY CORE]
   * called "#set_column_value" with updated_at=, 2015-07-07 19:16:24 -0700 [RUBY CORE]
   * called "#updated_at=" with 2015-07-07 19:16:24 -0700 [sequel-4.21.0/lib/sequel/model/base.rb:858]
   * called "#typecast_on_assignment" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db_schema" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#raise_on_typecast_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#model" [RUBY CORE]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#new?" [sequel-4.21.0/lib/sequel/model/base.rb:1454]
   * called "#model" [RUBY CORE]
   * called ".autoreloading_associations" [sequel-4.21.0/lib/sequel/model/associations.rb:1417]
   * called "#changed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:1252]
   * called "#raise_on_save_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#raise_on_save_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#errors" [sequel-4.21.0/lib/sequel/model/base.rb:1301]
   * called "#around_validation" [sequel-4.21.0/lib/sequel/model/base.rb:1124]
   * called "#before_validation" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#validate" [apps/website-report-service/app/models/website_report.rb:7]
   * called "#validates_presence" with user_id, url [sequel-4.21.0/lib/sequel/plugins/validation_helpers.rb:176]
   * called "#get_column_value" with user_id [RUBY CORE]
   * called "#user_id" [sequel-4.21.0/lib/sequel/model/base.rb:857]
   * called "#model" [RUBY CORE]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#get_column_value" with url [RUBY CORE]
   * called "#url" [sequel-4.21.0/lib/sequel/model/base.rb:857]
   * called "#model" [RUBY CORE]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#after_validation" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#errors" [sequel-4.21.0/lib/sequel/model/base.rb:1301]
   * called "#errors" [sequel-4.21.0/lib/sequel/model/base.rb:1301]
   * called "#raise_on_save_failure" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#use_transactions" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#use_transactions" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#model" [RUBY CORE]
   * called ".dataset" [sequel-4.21.0/lib/sequel/model/base.rb:157]
I, [2015-07-07T19:16:24.477282 #39091]  INFO -- : (0.000231s) BEGIN
   * called "#model" [RUBY CORE]
   * called ".dataset" [sequel-4.21.0/lib/sequel/model/base.rb:157]
   * called "#use_after_commit_rollback" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#frozen?" [RUBY CORE]
   * called "#use_after_commit_rollback" [sequel-4.21.0/lib/sequel/model/base.rb:1135]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#around_save" [sequel-4.21.0/lib/sequel/model/base.rb:1124]
   * called "#before_save" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#new?" [sequel-4.21.0/lib/sequel/model/base.rb:1454]
   * called "#around_create" [sequel-4.21.0/lib/sequel/model/base.rb:1124]
   * called "#before_create" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#model" [RUBY CORE]
   * called ".instance_dataset" [sequel-4.21.0/lib/sequel/model/base.rb:30]
I, [2015-07-07T19:16:24.479095 #39091]  INFO -- : (0.001098s) INSERT INTO "websites" ("user_id", "url", "created_at", "updated_at") VALUES (101, 'http://cnn.com', '2015-07-07 19:16:24.476029-0700', '2015-07-07 19:16:24.476029-0700') RETURNING *
   * called "#after_create" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#after_save" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#changed_columns" [sequel-4.21.0/lib/sequel/model/base.rb:1252]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
   * called "#db" [sequel-4.21.0/lib/sequel/model/base.rb:1130]
I, [2015-07-07T19:16:24.481081 #39091]  INFO -- : (0.000411s) COMMIT
   * called "#after_commit" [sequel-4.21.0/lib/sequel/model/base.rb:1123]
   * called "#inspect" [sequel-4.21.0/lib/sequel/model/base.rb:1368]
   * called "#model" [RUBY CORE]
   * called ".name" [RUBY CORE]
```

141 method calls to create a new record with 2 columns!


## Troubleshooting

Having problems? Maybe a specific method is throwing some obscure error? Try ignoring that method, so we can get back on track!

```ruby
MyKlass.track_not :bad_method
MyKlass.track_all! #=> will exclude tracking for :bad_method
```

## Issues

Doesn't work well (or at all) when trying to track Ruby core objects (`String`, `Array`, etc). You can work around this by
 subclassing the target class before extending with `ObjectTracker`. For example:

```ruby
class MyArray < Array
  extend ObjectTracker
end
```

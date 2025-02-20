class TestJob
  include Sidekiq::Job

  def perform(time, name,age)
    puts "I am #{name}, running my first job at #{age} and it ran #{time}"
    #any other valid Ruby/Rails code goes here!
  end
end

class TimelineController < AbstractTimelineController
  def viewDidLoad
    super

    self.title = 'Timeline'
  end

  def initWithNibName(name, bundle:bundle)
    super
    tabBarItem.image = UIImage.imageNamed('Chat')
    tabBarItem.title = 'Timeline'
    self
  end

  def load_timeline(&block)
    account.home_timeline(count: '20') do |data, error|
      App.alert('An error occurrred') if error
      load_data(data) if data
      block.call if block
    end
  end
end

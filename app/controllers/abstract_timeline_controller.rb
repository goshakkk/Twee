class AbstractTimelineController < UIViewController
  def self.controller
    @controller ||= alloc.initWithNibName(nil, bundle:nil)
  end

  def viewDidLoad
    super

    view.backgroundColor = UIColor.whiteColor

    @table = UITableView.alloc.initWithFrame(view.bounds, style:UITableViewStylePlain)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    @table.dataSource = self
    @table.delegate = self

    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action:'refreshTimeline', forControlEvents:UIControlEventValueChanged)
    @table.addSubview(@refresh)

    view.addSubview(@table)

    refreshButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemCompose, target:self, action:'compose'
    )
    navigationItem.rightBarButtonItem = refreshButton

    @timeline = []
    load_timeline
    async_load_timeline
  end

  def compose
    composeController = ComposeController.controller
    composeNavigationController = UINavigationController.alloc.init
    composeNavigationController.pushViewController(composeController, animated:false)

    presentModalViewController(composeNavigationController, animated:true)
  end

  def async_load_timeline
    @timer = NSTimer.scheduledTimerWithTimeInterval(
      60, target:self, selector:'load_timeline', userInfo:nil, repeats:true
    )
  end

  def load_data(data)
    Dispatch::Queue.main.sync do
      @timeline = data
      @table.reloadData
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @timeline.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    text = @timeline[indexPath.row]['text']
    font = UIFont.systemFontOfSize(15)
    size = text.sizeWithFont(font, constrainedToSize:[300.0, 640.0], lineBreakMode:NSLineBreakByWordWrapping)
    size.height + 15 + 20 # tweet size + by size + padding
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuse_id ||= 'TIMELINE_TWEET_CELL'

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_id)
    cell ||= UITableViewCell.alloc.initWithStyle(
      UITableViewCellStyleSubtitle, reuseIdentifier:@reuse_id
    )
    cell.selectionStyle = UITableViewCellSelectionStyleNone

    cell.textLabel.font = UIFont.boldSystemFontOfSize(15)
    cell.textLabel.text = "@#{@timeline[indexPath.row]['user']['screen_name']}"

    cell.detailTextLabel.font = UIFont.systemFontOfSize(15)
    cell.detailTextLabel.textColor = UIColor.blackColor
    cell.detailTextLabel.numberOfLines = 10
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping
    cell.detailTextLabel.text = @timeline[indexPath.row]['text']

    cell
  end

  def refreshTimeline
    load_timeline { @refresh.endRefreshing }
  end

  def refresh
  end

  def account
    App.delegate.account
  end
end

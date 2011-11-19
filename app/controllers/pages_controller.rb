class PagesController < ApplicationController
  
  skip_before_filter :fetch_logged_in_user, :only => [:iframe, :image]
  
  def index
    @pages = Page.existing
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = evaluate_partial_htmls p
    end      
    @pages_ids = @pages.collect{ |p| p.id }
  end

  def iframe
    @pages = Page.existing
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = evaluate_partial_htmls p
    end      
    @pages_ids = @pages.collect{ |p| p.id }
    render :index, :layout => 'iframe'
  end
  
  def update
    @page = Page.find_by_id params[:id]
    @page.update_attributes params[:page]
    @partial_htmls = evaluate_partial_htmls @page
    redirect_to edit_page_path @page
  end
  
  def new
    @page = Page.create
    redirect_to edit_page_path @page
  end
  
  def show
    @page = Page.find_by_id params[:id]
    @partial_htmls = evaluate_partial_htmls @page
    @previous_page, @next_page = neighbour_pages @page
  end

  def edit
    @page = Page.find_by_id params[:id]
    @partial_htmls = evaluate_partial_htmls @page
  end
  
  def find
      if params['search_text'].strip.length > 2
      search_terms = params['search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = 'hidden = false AND '
      conditions += (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND ')
      @found_articles = Article.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_options = Option.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_categories = Category.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_presentations = Presentation.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
    else
      render :nothing => true
    end
  end
  
  def destroy
    @page = Page.find_by_id params[:id]
    @page.destroy
    redirect_to pages_path
  end
  
  def image
    @page = Page.find_by_id params[:id]
    send_data @page.image, :type => @page.image_content_type, :disposition => 'inline' if @page.image
  end
  
  private
  
  def evaluate_partial_htmls(page)
    # this goes here because binding doesn't seem to work in views
    partials = page.partials
    partial_htmls = []
    partials.each do |partial|
      # the following 3 class varibles are needed for rendering the _partial partial
      record = partial.presentation.model.constantize.find_by_id partial.model_id
      begin
        eval partial.presentation.code
        partial_htmls[partial.id] = ERB.new(partial.presentation.markup).result binding
      rescue Exception => e
        partial_htmls[partial.id] = t('partials.error_during_evaluation') + e.message
      end
      partial_htmls[partial.id].force_encoding('UTF-8')
    end
    return partial_htmls
  end
  
  def neighbour_pages(page)
    pages = Page.existing
    idx = pages.index(page)
    previous_page = pages[idx-1]
    previous_page = page if idx.zero?
    next_page = pages[idx+1]
    next_page = page if next_page.nil?
    return previous_page, next_page
  end

end

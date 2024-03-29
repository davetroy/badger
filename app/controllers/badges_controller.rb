class BadgesController < ApplicationController
  http_basic_authenticate_with :name => "admin", :password => ADMIN_PASSWORD, :only => [:index, :new, :create, :destroy]
  
  # GET /badges
  # GET /badges.json
  def index
    session[:admin] = true
    @badges = Badge.order('approved_at desc,id')
    @fri_count = Badge.select { |b| b.friday? }.size
    @sat_count = Badge.select { |b| b.saturday? }.size

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @badges }
    end
  end

  # GET /badges/1
  # GET /badges/1.json
  def show
    @badge = Badge.find_by_key(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def logo
    @badge = Badge.find_by_key(params[:id])
    respond_to do |format|
      format.png do
        @badge.logo_count += 1
        @badge.save
        fn = Rails.root.join("app/assets/images", "logo.png")
        send_file fn, :type => 'image/png', :dispostion => 'inline'
      end
    end
  end

  # GET /badges/new
  # GET /badges/new.json
  def new
    @badge = Badge.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @badge }
    end
  end

  # GET /:id
  def edit
    session[:edited] = true
    @badge = Badge.find_by_key(params[:id])
    if !session[:admin] && (@badge.approved_at && (@badge.approved_at < 1.hour.ago) )
      redirect_to @badge, :notice => 'Badge has already been finalized.'
    end
    render :text => 'Error' unless @badge
  end

  # POST /badges
  # POST /badges.json
  def create
    @badge = Badge.new(params[:badge])

    respond_to do |format|
      if @badge.save
        format.html { redirect_to @badge, :notice => 'Badge was successfully created.' }
        format.json { render :json => @badge, :status => :created, :location => @badge }
      else
        format.html { render :action => "new" }
        format.json { render :json => @badge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /badges/1
  # PUT /badges/1.json
  def update
    @badge = Badge.find_by_key(params['id'])
    @badge.approved_at = Time.now unless session[:admin]
    respond_to do |format|
      if @badge.update_attributes(params[:badge])
        format.html { redirect_to @badge, :notice => 'Badge was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @badge = Badge.find_by_key(params[:id])
    @badge.destroy
    redirect_to badges_url
  end
  
end

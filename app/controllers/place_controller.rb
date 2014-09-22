class PlaceController < ApplicationController
  include AdminHelper
  before_filter :authenticate_admin, :validate_place_privileges
  def index
  end

  def add_country
    @country=Country.new
  end

  def create_country
    country_name=country_params[:name].to_s.strip.downcase
    @country=Country.new
    @country.name=country_name
    if @country.save
      flash[:success]="country created successfull"
      redirect_to place_path
    else
      render 'add_country'
    end
  end

  def add_governorate
    @governorate=Governorate.new
  end

  def create_governorate
    @parent_country=Country.find_by_id(governorate_params[:country_id])
    @governorate=Governorate.new
    @governorate.name=governorate_params[:name].to_s.strip.downcase
    @governorate.country_id = governorate_params[:country_id]
    @gov_name_exist = Governorate.where("country_id=? and name=?",@parent_country,@governorate.name).count
    if @gov_name_exist >0
      flash.now[:error] = "This governorate already exist in this country"
      render "add_governorate"
    return
    else
      if @governorate.save
        flash[:success]="governorate created successfull"
        redirect_to place_path
      return
      else
        render 'add_governorate'
      end
    end
  end

  def update_governorates
    @governorates = Governorate.where("country_id = ?", params[:country_id])
    respond_to do |format|
      format.js
    end
  end

  def add_region
    @region=Region.new
    @countries = Country.all
    @governorates = Governorate.where("country_id = ?", Country.first.id)
  end

  def create_region
    @parent_governorate=Governorate.find_by_id(region_params[:governorate_id])
    @region=Region.new
    @region.name = region_params[:name].to_s.strip.downcase
    @region.governorate_id = region_params[:governorate_id]
    @region_name_exist = Region.where("governorate_id=? and name=?",@parent_governorate,@region.name).count
    if @region_name_exist >0
      flash.now[:error] = "This region already exist in this governorate"
      @countries = Country.all
      @governorates = Governorate.where("country_id = ?", Country.first.id)
      render "add_region"
    return
    else
      if @region.save
        flash[:success]="region created successfull"
        redirect_to place_path
      return
      else
        @countries = Country.all
        @governorates = Governorate.where("country_id = ?", Country.first.id)
        render "add_region"
      end
    end
  end

  def countries
    empty_selectd_country_id
    empty_selectd_governorate_id
    empty_selectd_region_id
    @countries=Country.all.paginate(:page => params[:page],:per_page=>9)
  end

  def update_country
    @selected_country=Country.find(session[:selected_country_id])
    if @selected_country
      name=country_params[:name].to_s.strip.downcase
      country_params={:name=>name}
      if @selected_country.valid? && @selected_country.update_attributes(country_params)
        flash[:success]="Country  updated successfully #{@selected_country.name.mb_chars.length} "
        redirect_to countries_path
      else
        @governorates=Governorate.where("country_id=?", session[:selected_country_id]).
        paginate(:page => params[:page],:per_page=>9)
        render 'governorates'
      return
      end
    else
      flash[:error]="error"
      redirect_to countries_path
    end
  end

  def governorates
    empty_selectd_country_id
    empty_selectd_governorate_id
    empty_selectd_region_id
    country_id=params[:country_id]

    if country_id
      session[:selected_country_id]=country_id
      begin
        @selected_country=Country.find(session[:selected_country_id])
        @governorates=Governorate.where("country_id=?", session[:selected_country_id]).
      paginate(:page => params[:page],:per_page=>9)
      rescue
        redirect_to countries_path
      end
    else
      redirect_to countries_path
    end
  end

  def update_governorate
    @updated_governorate=Governorate.find(session[:selected_governorate_id])
    if @updated_governorate
      @gov_exist=Governorate.where("id !=? and name=? and country_id=?",session[:selected_governorate_id],governorate_params[:name].to_s.strip.downcase,governorate_params[:country_id]).count
      if @gov_exist >0
        @selected_governorate=Governorate.find(session[:selected_governorate_id])
        @regions=Region.where("governorate_id=?", session[:selected_governorate_id]).paginate(:page => params[:page],:per_page=>9)
        flash.now[:error] = "Governorate already exist in this Country"
        render 'regions'
      return
      else
        @updated_governorate.name=governorate_params[:name].to_s.strip.downcase
        if @updated_governorate.valid? &&  @updated_governorate.update_attributes(:name=>(governorate_params[:name].to_s.strip.downcase),:country_id=>governorate_params[:country_id])
          flash[:success]="Governorate updated successfully  "
          redirect_to countries_path
        return
        else
          @selected_governorate=Governorate.find(session[:selected_governorate_id])
          @regions=Region.where("governorate_id=?", session[:selected_governorate_id]).paginate(:page => params[:page],:per_page=>9)
          render 'regions'
        return
        end
      end
    else
      flash.now[:governorate_updated_error]="Governorate id session is empty"
    end
    redirect_to countries_path
  end

  def regions
    empty_selectd_country_id
    empty_selectd_region_id
    governorate_id=params[:governorate_id]

    if governorate_id || session[:selected_governorate_id]
      if ! session[:selected_governorate_id]
        session[:selected_governorate_id]=governorate_id
      end
      begin
        @selected_governorate=Governorate.find(session[:selected_governorate_id])
        @regions=Region.where("governorate_id=?", session[:selected_governorate_id]).
        paginate(:page => params[:page],:per_page=>9)
      rescue Exception => e
        redirect_to countries_path
      end
    else
      redirect_to countries_path
    end
  end

  def region
    region_id=params[:region_id]
    if region_id
      session[:selected_region_id]=region_id
      begin
        @selected_region=Region.find(session[:selected_region_id])
      rescue
        redirect_to countries_path
      end
    else
      redirect_to countries_path
    end
  end

  def update_region
    if session[:selected_region_id]
      @selected_region=Region.find(session[:selected_region_id])
      if @selected_region
        @region_name_exist=Region.where("id !=? and name=? and governorate_id=?",
        session[:selected_region_id],region_params[:name].to_s.strip.downcase,region_params[:governorate_id]).count
        if @region_name_exist > 0
          @selected_region=Region.find(session[:selected_region_id])
          flash.now[:error]="This region  already exists in this governorate"
          render 'region'
        else
          @selected_region.update_attributes(:name=>(region_params[:name].to_s.strip.downcase),:governorate_id=>region_params[:governorate_id])
          if @selected_region.valid?
            empty_selectd_region_id
            flash[:success]="region  updated successfully"
            session[:selected_governorate_id]=@selected_region.governorate_id
            redirect_to regions_path
          else
            render 'region'
          end
        end
      else
        flash.now[:error]="region is invalid  "
        redirect_to admin_index_path
      end
    else
      flash.now[:error]="Not authorized  "
      redirect_to admin_index_path
    end
  end

  def validate_place_privileges
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '4'
        redirect_to admin_index_path
      end
    end
  end
  private

  def empty_selectd_country_id
    session[:selected_country_id]=nil
  end

  def empty_selectd_governorate_id
    session[:selected_governorate_id]=nil
  end

  def empty_selectd_region_id
    session[:selected_region_id]=nil
  end

  def country_params
    params.required(:country).permit(:name)
  end

  def governorate_params
    params.require(:governorate).permit(:country_id,:name)
  end

  def region_params
    params.require(:region).permit(:name, :governorate_id)
  end
end

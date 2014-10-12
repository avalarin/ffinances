module Admin
  class UserController < AdminBaseController
    include DatatableHelper

    def index
      page = params[:page] ? [1, params[:page].to_i].max : 1
      per_page = get_table_page_size :admin_users
      filter = params[:filter] ? params[:filter].to_sym : :all
      search = params[:search] || ''

      @users = User.filter(filter).search(search)
      all_count = @users.count
      @users = @users.order('display_name asc').paginate(page: page, per_page: per_page)

      respond_to do |format|
        format.html { 
          @filters = user_filters
          render 
        }
        format.json { render :json => wrap_users(@users, all_count, page, per_page, filter).to_json }
      end
    end

    def create
      permited = params.require(:user).permit(:name, :display_name, :email, :password, :password_confirmation, :commit)
      user = User.new permited
      user.activation_code = SecureRandom.uuid
      if user.valid?
        user.save!
        UserMailer.success_registration(user).deliver
        render_api_resp :ok, data: wrap_user(user)
      else
        render_model_errors_api_resp user
      end
    end

    def update
      permited = params.require(:user).permit(:display_name, :email, :password, 
        :password_confirmation, :confirmed, :locked)
      user = User.find_by_name params.require(:user_name)
      return render_not_found unless user
      permited.each_pair do |k, v|
        user.send("#{k}=", v)
      end
      if user.valid?
        user.save!
        render_api_resp :ok, data: wrap_user(user)
      else
        render_model_errors_api_resp user
      end
    end

    def send_confirmation_email
      user = User.find_by_name params.require(:user_name)
      return render_not_found unless user
      if (!user.confirmed)
        UserMailer.email_confirmation(user).deliver
        render_api_resp :ok, data: wrap_user(user)
      else
        render_api_resp :bad_request, message: 'already_confirmed'
      end
    end

    def wrap_users users, all_count, page, per_page, filter
      collected = users.collect { |u| wrap_user u }
      { items: collected, page: page, pages: 1, count: all_count,
        perPage: per_page, filter: filter }
    end

    def wrap_user u
      { name: u.name, 
        display_name: u.display_name,
        email: u.email,
        roles: u.roles, 
        is_current: u.name == current_user.name,
        is_confirmed: u.confirmed, 
        is_locked: u.locked,
        avatar_url: u.avatar_url
      }
    end

    def user_filters
      { all: { text: t('.filter_all'), icon: "users" },                                
        locked: { text: t('.filter_locked'), icon: "users" },                                
        not_confirmed: { text: t('.filter_not_confirmed'), icon: "users" }                               
      }
    end

  end
end
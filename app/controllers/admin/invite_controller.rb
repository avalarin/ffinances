module Admin
  class InviteController < AdminBaseController
    include DatatableHelper
    
    def index
      page = params[:page] ? [1, params[:page].to_i].max : 1
      per_page = get_table_page_size :admin_invites
      filter = params[:filter] ? params[:filter].to_sym : :all
      @invites = Invite.filter(filter)
      all_count = @invites.count
      @invites = @invites.order('created_at desc').paginate(page: page, per_page: per_page)

      respond_to do |format|
        format.html { 
          @filters = invite_filters
          render 
        }
        format.json { render :json => wrap_invites(@invites, all_count, page, per_page, filter).to_json }
      end
    end

    def create
      invite = Invite.new code: (0...14).map { (65 + rand(26)).chr }.join, activated: false, email: params[:email]
      if (invite.valid?)
        invite.save!
        render_api_resp :ok, data: wrap_invite(invite)
      else
        render_model_errors_api_resp invite
      end
    end

    def delete
      invite = Invite.find_by_code params.require(:code)
      return render_not_found unless invite
      return render_api_resp(:bad_request, message: 'already_activated') if invite.activated
      invite.destroy
      render_api_resp :ok
    end

    def invite_filters
      { all: { text: t('.filter_all'), icon: "ticket" },                                
        free: { text: t('.filter_free'), icon: "ticket" },                                
        activated: { text: t('.filter_activated'), icon: "ticket" }                               
      }
    end

    def wrap_invites invites, all_count, page, per_page, filter
      collected = invites.collect { |i| wrap_invite i }
      { items: collected, page: page, pages: 1, count: all_count,
        perPage: per_page, filter: filter }
    end

    def wrap_invite i
      { id: i.id, code: i.code, email: i.email, activated: i.activated, user: i.user, 
        link: register_url(invite: i.code) }
    end

  end
end
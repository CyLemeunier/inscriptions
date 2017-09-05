class TournamentsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :set_tournament, only: [:show, :edit, :update, :destroy]

  def index
    # @tournaments_september = Tournament.where(date: Date.new(2016, 9, 1)...Date.new(2016, 10, 1)).order(:date)
    # @september = { name: "Septembre 2016", array: @tournaments_september}
    @tournaments_october = Tournament.where(date: Date.new(2016, 10, 1)...Date.new(2016, 11, 1)).order(:date)
    @october = { name: "Octobre 2016", array: @tournaments_october}
    @tournaments_november = Tournament.where(date: Date.new(2016, 11, 1)...Date.new(2016, 12, 1)).order(:date)
    @november ={ name: "Novembre 2016", array: @tournaments_november}
    @tournaments_december = Tournament.where(date: Date.new(2016, 12, 1)...Date.new(2017, 1, 1)).order(:date)
    @december = { name: "Décembre 2016", array: @tournaments_december}
    @tournaments_january = Tournament.where(date: Date.new(2017, 1, 1)...Date.new(2017, 2, 1)).order(:date)
    @january = { name: "Janvier 2017", array: @tournaments_january}
    @tournaments_february = Tournament.where(date: Date.new(2017, 2, 1)...Date.new(2017, 3, 1)).order(:date)
    @february = { name: "Février 2017", array: @tournaments_february}
    @tournaments_march = Tournament.where(date: Date.new(2017, 3, 1)...Date.new(2017, 4, 1)).order(:date)
    @march = { name: "Mars 2017", array: @tournaments_march}
    @tournaments_april = Tournament.where(date: Date.new(2017, 4, 1)...Date.new(2017, 5, 1)).order(:date)
    @april = { name: "Avril 2017", array: @tournaments_april}
    @tournaments_may = Tournament.where(date: Date.new(2017, 5, 1)...Date.new(2017, 6, 1)).order(:date)
    @may = { name: "Mai 2017", array: @tournaments_may}
    @tournaments_june = Tournament.where(date: Date.new(2017, 6, 1)...Date.new(2017, 7, 1)).order(:date)
    @june = { name: "Juin 2017", array: @tournaments_june}
    @tournaments_july = Tournament.where(date: Date.new(2017, 7, 1)...Date.new(2017, 8, 1)).order(:date)
    @july = { name: "Juillet 2017", array: @tournaments_july}

    @tournaments_september17 = Tournament.where(date: Date.new(2017, 9, 1)...Date.new(2017, 10, 1)).order(:date)
    @september17 = { name: "Septembre 2017", array: @tournaments_september17}
    @tournaments_october17 = Tournament.where(date: Date.new(2017, 10, 1)...Date.new(2017, 11, 1)).order(:date)
    @october17 = { name: "Octobre 2017", array: @tournaments_october17}
    @tournaments_november17 = Tournament.where(date: Date.new(2017, 11, 1)...Date.new(2017, 12, 1)).order(:date)
    @november17 ={ name: "Novembre 2017", array: @tournaments_november17}
    @tournaments_december17 = Tournament.where(date: Date.new(2017, 12, 1)...Date.new(2018, 1, 1)).order(:date)
    @december17 = { name: "Décembre 2017", array: @tournaments_december17}
    @tournaments_january18 = Tournament.where(date: Date.new(2018, 1, 1)...Date.new(2018, 2, 1)).order(:date)
    @january18 = { name: "Janvier 2018", array: @tournaments_january18}
    @tournaments_february18 = Tournament.where(date: Date.new(2018, 2, 1)...Date.new(2018, 3, 1)).order(:date)
    @february18 = { name: "Février 2018", array: @tournaments_february18}
    @tournaments_march18 = Tournament.where(date: Date.new(2018, 3, 1)...Date.new(2018, 4, 1)).order(:date)
    @march18 = { name: "Mars 2018", array: @tournaments_march18}
    @tournaments_april18 = Tournament.where(date: Date.new(2018, 4, 1)...Date.new(2018, 5, 1)).order(:date)
    @april18 = { name: "Avril 2018", array: @tournaments_april18}
    @tournaments_may18 = Tournament.where(date: Date.new(2018, 5, 1)...Date.new(2018, 6, 1)).order(:date)
    @may18 = { name: "Mai 2018", array: @tournaments_may18}
    @tournaments_june18 = Tournament.where(date: Date.new(2018, 6, 1)...Date.new(2018, 7, 1)).order(:date)
    @june18 = { name: "Juin 2018", array: @tournaments_june18}
    @tournaments_july18 = Tournament.where(date: Date.new(2018, 7, 1)...Date.new(2018, 8, 1)).order(:date)
    @july18 = { name: "Juillet 2018", array: @tournaments_july18}
    @last_tournaments = [@october, @november, @december,@january, @february, @march, @april, @may, @june, @july]
    @tournaments = [@september17, @october17, @november17, @december17, @january18, @february18, @march18, @april18, @may18, @june18, @july18]


  end

  def show
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.new(tournament_params)

    date = Date.parse(tournament_params["date"])
    @tournament.date = date
    city = tournament_params["city"].capitalize
    @tournament.city = city
    @tournament.save
    redirect_to tournaments_path
  end

  def edit

  end

  def update
    @tournament.update(tournament_params)
    redirect_to tournaments_path
  end

  def update_tournoiclub
    @tournament = Tournament.find(params[:tournament_id])
    @registrations_by_tournaments = Registration.joins(:tournament).
                                  joins(:player).
                                  where(:tournament_id => params["tournament_id"])

    @registrations_by_tournaments.each do |registration|
      player = Player.find(registration.player_id)
      player.credit += registration.price
      player.save

      transaction = Transaction.new
      transaction.player_id = player.id.to_i
      transaction.amount = registration.price
      transaction.reason = "(CREDIT) Tournoi de #{@tournament.city} --> tournoi club"
      transaction.save

    end

    if @tournament.price2 == nil
      @tournament.update("price1" => params["price1"].to_i)
    elsif @tournament.price3 == nil
      @tournament.update(
                        "price1" => params["price1"].to_i,
                        "price2" => params["price2"].to_i
                        )
    else
      @tournament.update(
                          "price1" => params["price1"].to_i,
                          "price2" => params["price2"].to_i,
                          "price3" => params["price3"].to_i
                          )
    end
    redirect_to tournaments_path
  end

  def destroy
    @tournament.destroy
    redirect_to tournaments_path
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:city, :date, :date2, :tableau, :serie, :price1, :price2, :price3, :deadline, :comment, :address)
  end
end

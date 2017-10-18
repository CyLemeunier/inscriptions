class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :new, :create]

  def all_registrations
    @registrations_by_tournaments = Registration.includes(:tournament).
                                  includes(:player).sort_by{ |r| [r.created_at, r.player.last_name] }.reverse
  end

  def index
    @tournament = Tournament.find(params["tournament_id"])
    @registrations_by_tournaments = Registration.joins(:tournament).
                                  joins(:player).
                                  where(:tournament_id => params["tournament_id"])

    # Somme du montant des inscriptions
    @sum = 0
    @registrations_by_tournaments.each do |registration|
      @sum += registration.price
    end
    @sum
    # Génération du fichier excel pour l'envoi des inscriptions
    respond_to do |format|
      format.html
      format.xls { response.headers['Content-Disposition'] = "attachment; filename=\"#{@registrations_by_tournaments.first.tournament.city}_#{Date.today.strftime("%d-%m-%Y")}.xls\"" }
    end
  end

  def show
  end

  def new
    @tournament = Tournament.find(params["tournament_id"])
    @all_players = Player.name_with_credit
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(registration_params)
    @player = Player.find(registration_params["player_id"].to_i)
    @tournament = Tournament.find(registration_params["tournament_id"].to_i)

    if @registration.save
      tableau2 = registration_params["tableau2"]
      serie2 = registration_params["serie2"]
      tableau3 = registration_params["tableau3"]
      serie3 = registration_params["serie3"]

      if tableau2 == nil || tableau2 == ""
        @registration.price = @tournament.price1
      elsif tableau3 == nil || tableau3 == ""
        @registration.price = @tournament.price2
      else
        @registration.price = @tournament.price3
      end

      if @player.credit < @registration.price
        redirect_to '/credit_insuffisant'
      else
        new_credit = @player.credit - @registration.price
        @player.credit = new_credit
        @player.save
        @registration.save

        transaction = Transaction.new
        transaction.player_id = @player.id.to_i
        transaction.amount = @registration.price
        transaction.reason = "(DEBIT) Inscription au tournoi de #{@tournament.city}"
        transaction.save

      redirect_to tournaments_path
      end
    else
      respond_to do |format|
        format.html { render 'registrations/new' }
      end
    end
  end

  def edit
    @tournament = Tournament.find(params["tournament_id"].to_i)
    @registration = Registration.find(params["id"])
    @player = Player.find(@registration.player_id)
  end

  def update
    @tournament = Tournament.find(registration_params["tournament_id"].to_i)
    @player = Player.find(registration_params["player_id"].to_i)
    @registration = Registration.find(params["id"])
    price_before = @registration.price

    tableau2 = registration_params["tableau2"]
    serie2 = registration_params["serie2"]
    tableau3 = registration_params["tableau3"]
    serie3 = registration_params["serie3"]

    # only 1 tableau
    if tableau2 == nil || tableau2 == ""

      # 1 or 2 tableaux deleted
      if price_before > @tournament.price1

        # re-créditation de la différence de prix
        minus_charge = price_before - @tournament.price1
        new_credit = @player.credit + minus_charge
        @player.credit = new_credit
        @player.save

        # save a transaction
        transaction = Transaction.new
        transaction.player_id = @player.id.to_i
        transaction.amount = minus_charge
        transaction.reason = "(CREDIT) Suppression de tableau(x) au tournoi de #{@tournament.city}"
        transaction.save

      end

      # màj de la registration
      @registration.update(
                            "tableau1"=>registration_params["tableau1"],
                            "serie1"=>registration_params["serie1"],
                            "tableau2"=>registration_params["tableau2"],
                            "serie2"=>registration_params["serie2"],
                            "tableau3"=>registration_params["tableau3"],
                            "serie3"=>registration_params["serie3"],
                            "com1"=>registration_params["com1"],
                            "com2"=>registration_params["com2"],
                            "com3"=>registration_params["com3"],
                            "price" => @tournament.price1)

      redirect_to tournament_registrations_path(:tournament_id => registration_params["tournament_id"].to_i)

    # only 2  tableaux
    elsif tableau3 == nil || tableau3 == ""

      # check if 1 tableau added ou deleted

      # 1 tableau is added
      if price_before < @tournament.price2
        # différence de prix
        @extra_charge = @tournament.price2 - price_before

        # call private def
        debit_check_and_update_credit_and_save_registration

      # else a tableau is deleted
      else
        # différence de prix
        minus_charge = price_before - @tournament.price2

        # re-créditation de la différence de prix
        new_credit = @player.credit + minus_charge
        @player.credit = new_credit
        @player.save

        # save a transaction
        transaction = Transaction.new
        transaction.player_id = @player.id.to_i
        transaction.amount = minus_charge
        transaction.reason = "(CREDIT) Suppression de tableau(x) au tournoi de #{@tournament.city}"
        transaction.save

        redirect_to tournament_registrations_path(:tournament_id => registration_params["tournament_id"].to_i)
      end

      # màj de la registration
      @registration.update(
                            "tableau1"=>registration_params["tableau1"],
                            "serie1"=>registration_params["serie1"],
                            "tableau2"=>registration_params["tableau2"],
                            "serie2"=>registration_params["serie2"],
                            "tableau3"=>registration_params["tableau3"],
                            "serie3"=>registration_params["serie3"],
                            "com1"=>registration_params["com1"],
                            "com2"=>registration_params["com2"],
                            "com3"=>registration_params["com3"],
                            "price" => @tournament.price2)

    else # 3 tableaux

      # check if a tableau is added
      if price_before < @tournament.price3

        # différence de prix
        @extra_charge = @tournament.price3 - price_before
        # call private def
        debit_check_and_update_credit_and_save_registration

      end

      # màj de la registration
      @registration.update(
                            "tableau1"=>registration_params["tableau1"],
                            "serie1"=>registration_params["serie1"],
                            "tableau2"=>registration_params["tableau2"],
                            "serie2"=>registration_params["serie2"],
                            "tableau3"=>registration_params["tableau3"],
                            "serie3"=>registration_params["serie3"],
                            "com1"=>registration_params["com1"],
                            "com2"=>registration_params["com2"],
                            "com3"=>registration_params["com3"],
                            "price" => @tournament.price3)
    # Define the new price - END

    end
  end

  def destroy
    @registration = Registration.find(params[:id])
    player = Player.find(@registration.player_id.to_i)
    tournament = Tournament.find(@registration.tournament_id.to_i)

    # réaffecter le solde du joueur
    new_credit = player.credit + @registration.price
    player.credit = new_credit
    player.save

    # save a transaction
    transaction = Transaction.new
    transaction.player_id = player.id.to_i
    transaction.amount = @registration.price
    transaction.reason = "(CREDIT) Suppression de l'inscription au tournoi de #{tournament.city}"
    transaction.save

    @registration.destroy


    redirect_to tournament_registrations_path(:tournament_id => params["tournament_id"].to_i)
  end

  private

  def set_registration
    @registration = Registration.find(params[:id])
  end

  def registration_params
    params.require(:registration).permit(:tournament_id, :player_id, :tableau1, :serie1, :tableau2, :serie2, :tableau3, :serie3, :com1, :com2, :com3)
  end

  def debit_check_and_update_credit_and_save_registration
    if @player.credit < @extra_charge
      redirect_to '/credit_insuffisant'
    else

      # débit de la différence de prix
      new_credit = @player.credit - @extra_charge
      @player.credit = new_credit
      @player.save

      # save a transaction
      transaction = Transaction.new
      transaction.player_id = @player.id.to_i
      transaction.amount = @extra_charge
      transaction.reason = "(DEBIT) Ajout de tableau(x) au tournoi de #{@tournament.city}"
      transaction.save

      redirect_to tournament_registrations_path(:tournament_id => registration_params["tournament_id"].to_i)


    end
  end
end


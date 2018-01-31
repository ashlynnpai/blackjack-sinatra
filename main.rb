require 'rubygems'
require 'sinatra'

if ENV['RACK_ENV'] != 'production'
   require 'sinatra/reloader'
   require 'byebug'
end

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'ejsresrt'

helpers do
  def avatar(num)
    session[:chosen] = params[:chosen]
    if num == 1
      session[:chosen] = "<img src='/images/avatar1.png'>"
    elsif num == 2
      session[:chosen] = "<img src='/images/avatar2.png'>"
    elsif num == 3
      session[:chosen] = "<img src='/images/avatar3.png'>"
    elsif num == 4
      session[:chosen] = "<img src='/images/avatar4.png'>"
    else
      session[:chosen] = "<img src='/images/avatar5.png'>"
    end
  end

  def image(card)
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='face'>"
  end

  def total(cards)
    arr = cards.map{|card| card[1] }
    total = 0
    arr.each do |value|
      if value == "ace"
        total += 11
      elsif value.to_i == 0 # J, Q, K
        total += 10
      else
        total += value.to_i
      end
    end
    arr.select{|value| value == "ace"}.count.times do
    total -= 10 if total > 21
    end
  total
  end

  def game_over(player_total, dealer_total)
    @buttons = false
    x = session[:player_total] <=> session[:dealer_total]
    if x == 0
      @message1="It's a tie!"
      session[:turn] = "dealer"
      total_money("tie")
    elsif x == 1
      @message1="Player wins!"
      session[:turn] = "dealer"
      total_money("win")
    elsif x == -1
      @message1="Dealer wins!"
      session[:turn] = "dealer"
      total_money("lose")
    end
  erb :game
  end

  def bust(total)
    if session[:player_total]>21
      @message1="Player busts!"
      session[:turn] = "dealer"
      @buttons = false
      total_money("lose")
    elsif session[:dealer_total]>21
      @message1="Dealer busts!"
      total_money("win")
    else return nil
    end
  erb :game
  end

  def total_money(outcome)
    bet = session[:bet]
    bet = bet.to_i
      if outcome == "win"
        session[:money] += bet
      elsif outcome == "lose"
        session[:money] -= bet
      end
    money = session[:money]
      if outcome != "tie"
        @message2 = "You #{outcome} $#{bet}.  You have $#{money} left."
      else
        @message2 = "You tie/push.  You have $#{money} left."
      end
    @message3 = "Change Bet: start a new game with a different bet<br>
New Game: start a new game with the same bet<br>
Change Player: start a new player and change your bet<br>
Change Avatar: select a new avatar and change your bet"
  end
end

before do
  @buttons = true
  @hit = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    erb :set_name
  end
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/avatar'
end

get '/avatar' do
  erb :avatar
end

post '/avatar' do
  session[:avatar] = params[:avatar]
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  session[:bet] = params[:bet]
  redirect '/game'
end

get '/game' do
  if session[:money] <= 0
    redirect '/set_name'
  end
  bet = session[:bet]
  bet = bet.to_i
  if bet<10 || bet>session[:money]
    redirect '/bet'
  end
  session[:turn] = session[:player_name]

    num = session[:avatar]
    num = num.to_i
    avatar(num)

  suits = ['hearts', 'diamonds', 'spades', 'clubs']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king', 'ace']
  session[:deck] = suits.product(values).shuffle!

  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  session[:player_total] = total(session[:player_cards])
  session[:dealer_total] = total(session[:dealer_cards])

  if session[:player_total] == 21 || session[:dealer_total] == 21
    game_over(session[:player_total], session[:dealer_total])
  end

erb :game
end

post '/game/hit' do
  session[:player_cards] << session[:deck].pop
  session[:player_total] = total(session[:player_cards])
    if total(session[:player_cards])>21
      bust(session[:player_total])
    elsif total(session[:player_cards])==21
      @hit=false
    end
  erb :game, layout: false
end

post '/game/stand' do
  session[:turn] = "dealer"
  @buttons = false
  dealer_total = total(session[:dealer_cards])

  while total(session[:dealer_cards])<17
    session[:dealer_cards] << session[:deck].pop
    session[:dealer_total] = total(session[:dealer_cards])
  end
    if total(session[:dealer_cards])>21
      bust(session[:dealer_total])
    elsif total(session[:dealer_cards])>16
       game_over(session[:player_total], session[:dealer_total])
    end
  erb :game, layout: false
end

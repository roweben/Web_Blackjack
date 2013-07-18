require 'rubygems'
require 'sinatra'
require 'thin'

set :sessions, true

helpers do

  def get_hand_value(cards)
    total = 0
    cards.each do |card|
      card_value = case card[1..card.size-1]
        when 'A' then 11   
        when 'K' then 10
        when 'Q' then 10
        when 'J' then 10
      else
        card[1..card.size-1].to_i
      end 
        total += card_value 
    end
    total
  end 

  def is_blackjack?
  end

  def is_busted?
  end

  def get_suit(suit)
    suit_name = case suit 
      when 'H' then 'hearts' 
      when 'C' then 'clubs' 
      when 'D' then 'diamonds' 
      when 'S' then 'spades' 
    end
    suit_name
  end

  def get_face_value(face)
   face_value = case face
       when 'A' then 'ace' 
       when 'J' then 'jack' 
       when 'Q' then 'queen' 
       when 'K' then 'king' 
       else face.to_i 
    end 
    face_value
  end

  def adj_total(value)
  end

  def get_html_for_image_names(cards, p_or_d)
    image_names = ''
    for x in 0..cards.size-1
      if p_or_d == 'dealer' && x == 0 && session[:turn] == 'player'
        image_names += "<td><img src=\"../images/cards/cover.jpg\" 
                      width=\"100\" height=\"150\" alt=\"First Card Not Shown\" /></td> "
      else
        card = cards[x] 
        suit = get_suit(card[0])
        fv = get_face_value(card[1..card.size-1])
        image_names += "<td><img src=\"../images/cards/#{suit}_#{fv}.jpg\" 
                      width=\"100\" height=\"150\" alt=\"#{fv} of 
                      #{suit.capitalize}\" /></td> "
      end
    end
    image_names
  end

end


get '/' do  
  if session[:player_name]
    redirect '/blackjack'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/blackjack'
end

get '/blackjack' do
  suits = ['H', 'C', 'D', 'S']
  faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  deck = []
  suits.each do |s|
    faces.each do |f|
      deck.push(s+f)
    end
  end
  p_cards = []
  d_cards = []
  p_cards.push deck.delete_at(rand(deck.size))
  d_cards.push deck.delete_at(rand(deck.size))
  p_cards.push deck.delete_at(rand(deck.size))
  d_cards.push deck.delete_at(rand(deck.size))
  session[:deck] = deck
  session[:p_cards] = p_cards
  session[:d_cards] = d_cards
  session[:turn] = 'player'
  erb :"/games/blackjack"
end

post '/blackjack' do
  if params[:hit]
    session[:p_cards].push session[:deck].delete_at(rand(session[:deck].size))
  end
  if params[:stay]
    session[:turn] = 'dealer'
  end
  erb :"/games/blackjack"
end

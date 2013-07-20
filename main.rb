require 'rubygems'
require 'sinatra'
require 'thin'

set :sessions, true

helpers do

  def get_hand_total(cards)
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
    if total > 21
      total = adj_total(total, cards)
    end
    total
  end 

  def status_check(p_or_d_cards, p_or_d)
    if get_hand_total(p_or_d_cards) == 21
      session[:play_on] = 1
      return 'BLACKJACK'
    elsif get_hand_total(p_or_d_cards) > 21
      session[:play_on] = 1
      return 'BUSTED'
    elsif p_or_d == 'dealer'
      if get_hand_total(session[:d_cards]) > get_hand_total(session[:p_cards])
        session[:play_on] = 1
        return 'Dealer wins!!'
      elsif get_hand_total(session[:d_cards]) == get_hand_total(session[:p_cards])
        session[:play_on] = 1
        return "It's a push!"
      end
    end
    ''
  end
  
  def deal_a_card(p_or_d_cards)
    if session[:deck].size == 0
      create_deck
    end
    p_or_d_cards.push session[:deck].delete_at(rand(session[:deck].size))
    end
  end
  
  def create_deck
    suits = ['H', 'C', 'D', 'S']
    faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    deck = []
    suits.each do |s|
      faces.each do |f|
        deck.push(s+f)
      end
    end
    session[:deck] = deck
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

  def adj_total(total, cards)
    ace_count = 0
    cards.each do |card|
      if card[1] == 'A'
        ace_count += 1
      end
    end
    while total > 21 and ace_count > 0
      total -= 10
      ace_count -= 1
    end
    total
  end

  def get_html_for_image_names(cards, p_or_d)
    image_names = ''
    for x in 0..cards.size-1
      if p_or_d == 'dealer' && x == 0 && session[:turn] == 'player'
        image_names += "<td style=\"padding:5px; \"><img src=\"../images/cards/cover.jpg\" 
                      width=\"100\" height=\"150\" alt=\"First Card Not Shown\" /></td> "
      else
        card = cards[x] 
        suit = get_suit(card[0])
        fv = get_face_value(card[1..card.size-1])
        image_names += "<td style=\"padding:5px; \"><img src=\"../images/cards/#{suit}_#{fv}.jpg\" 
                      width=\"100\" height=\"150\" alt=\"#{fv} of 
                      #{suit.capitalize}\" /></td> "
      end
    end
    image_names
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
  create_deck
  p_cards = []
  d_cards = []
  session[:p_cards] = p_cards
  session[:d_cards] = d_cards
  deal_a_card(session[:p_cards])
  deal_a_card(session[:d_cards])
  deal_a_card(session[:p_cards])
  deal_a_card(session[:d_cards])
  session[:turn] = 'player'
  session[:play_on] = 0
  erb :"/games/blackjack"
end

post '/blackjack' do
  if params[:hit]
    deal_a_card(session[:p_cards])
  end
  if params[:stay]
    session[:turn] = 'dealer'
  end
  if params[:play_again]
    session[:p_cards] = []
    session[:d_cards] = []
    deal_a_card(session[:p_cards])
    deal_a_card(session[:d_cards])
    deal_a_card(session[:p_cards])
    deal_a_card(session[:d_cards])
    session[:turn] = 'player'
    session[:play_on] = 0
  end 
  if params[:dealer_turn]
    deal_a_card(session[:d_cards])
  end
  erb :"/games/blackjack"
end

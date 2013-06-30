require 'poker'
require 'rspec'

describe Card do

  subject(:card) {Card.new(4, :hearts)}

  its(:val) {should == 4}

  its(:suit) {should == :hearts}

  describe "#render" do

    it "prints out the value and suit" do
      card = Card.new(5, :clubs)
      card.val.should == 5
      card.suit.should == :clubs
      card.render.should == "5 of clubs"
    end

    it "prints out symbols for non-number cards" do
      card = Card.new(13, :spades)
      card.render.should == "K of spades"
    end


  end

  
end

describe Deck do

  subject(:deck) {Deck.new}

  it "contains 52 cards" do
    deck.all_cards.count.should == 52
    
  end

  let(:card) {double("card")}
  it "contains only one ace of spades" do
    
    aces_of_spades = deck.all_cards.select {|card| card.val == 14 && card.suit == :spades}
    aces_of_spades.count.should == 1


  end

  it "contains four kings" do
    kings = deck.all_cards.select {|card| card.val == 13}
    kings.count.should == 4
  end

  it "contains thirteen diamonds" do
    diamonds = deck.all_cards.select {|card| card.suit == :diamonds}
    diamonds.count.should == 13
  end

  describe "#deal" do
    it "does not deal the same card twice" do
      
      deck.deal(1).should_not == deck.deal(1)
    end

    it "separates dealt cards into a dealt card pile" do
      card = deck.deal(1)[0]
      deck.dealt_cards.include?(card).should == true
      

    end

    it "does not deal a card that has already been dealt" do
      card = deck.deal(1)[0]
      deck.unused_cards.include?(card).should == false
    end

    it "can deal more than one card at a time" do
      cards = deck.deal(2)
      cards.count.should == 2
    end
  end


end

describe Hand do
  subject(:hand) {Hand.new}
  let(:deck) {Deck.new}
  it "contains five cards" do
    hand.new_hand(deck)
    hand.hand_cards.count.should == 5

  end

  describe "#discard" do
    it "replaces a card in your hand" do
      hand.new_hand(deck)
      original_card = hand.hand_cards[0]
      hand.discard([0], deck)
      expect(deck.unused_cards.include?(original_card)).to eq(true)
      hand.hand_cards[0].should_not == original_card

    end

  end

  describe "#straight?" do
    it "detects a straight" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(7, :hearts)
      hand.hand_cards[1] = Card.new(6, :spades)
      hand.hand_cards[2] = Card.new(5, :hearts)
      hand.hand_cards[3] = Card.new(4, :spades)
      hand.hand_cards[4] = Card.new(3, :clubs)
      hand.straight?.should == true
    end

    it "checks if you can make a straight by putting an ace as a 1 instead of a high card" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(14, :spades)
      hand.hand_cards[1] = Card.new(2, :spades)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(4, :spades)
      hand.hand_cards[4] = Card.new(5, :hearts)
      hand.straight?.should == true
    end
  end

  describe "#straight_flush?" do
    it "detects a straight flush" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(7, :hearts)
      hand.hand_cards[1] = Card.new(6, :hearts)
      hand.hand_cards[2] = Card.new(5, :hearts)
      hand.hand_cards[3] = Card.new(4, :hearts)
      hand.hand_cards[4] = Card.new(3, :hearts)
      hand.straight_flush?.should == true
    end

    it "detects a straight flush when you put the ace as the low card" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(5, :spades)
      hand.hand_cards[1] = Card.new(14, :spades)
      hand.hand_cards[2] = Card.new(3, :spades)
      hand.hand_cards[3] = Card.new(4, :spades)
      hand.hand_cards[4] = Card.new(2, :spades)
      hand.straight_flush?.should == true
    end
  end

  describe "#flush?" do
    it "detects a flush" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(11, :clubs)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(14, :clubs)
      hand.hand_cards[3] = Card.new(2, :clubs)
      hand.hand_cards[4] = Card.new(3, :clubs)
      hand.flush?.should == true
    end
  end

  describe "#royal_flush?" do
    it "detects a royal flush" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(14, :spades)
      hand.hand_cards[1] = Card.new(13, :spades)
      hand.hand_cards[2] = Card.new(12, :spades)
      hand.hand_cards[3] = Card.new(11, :spades)
      hand.hand_cards[4] = Card.new(10, :spades)
      hand.flush?.should == true

    end
  end


  

  
  describe "#four_of_a_kind?" do
    it "detects four of a kind" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(5, :spades)
      hand.hand_cards[1] = Card.new(2, :clubs)
      hand.hand_cards[2] = Card.new(5, :clubs)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(5, :diamonds)
      hand.four_of_a_kind?.should == true
      hand.flush?.should == false
      hand.straight?.should == false
    end

    it "reorders the cards if there's four of a kind and the odd card out is higher than the other four" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(3, :spades)
      hand.hand_cards[1] = Card.new(7, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(3, :hearts)
      hand.hand_cards[4] = Card.new(3, :diamonds)
      hand.four_of_a_kind?.should == true
      hand.hand_cards[4].val.should == 7 #the seven card should be put last
    end
  end

  describe "#full_house?" do
    it "detects a full house" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(6, :spades)
      hand.hand_cards[1] = Card.new(2, :clubs)
      hand.hand_cards[2] = Card.new(6, :clubs)
      hand.hand_cards[3] = Card.new(2, :hearts)
      hand.hand_cards[4] = Card.new(2, :diamonds)
      hand.full_house?.should == true
      hand.hand_cards[0].val.should == 2
      hand.hand_cards[4].val.should == 6 #it's in the right order (the three cards first then the pair)
    end
  end

  describe "#three_of_a_kind?" do
    it "detects three of a kind" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(5, :spades)
      hand.hand_cards[1] = Card.new(2, :clubs)
      hand.hand_cards[2] = Card.new(5, :clubs)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.three_of_a_kind?.should == true
      hand.hand_cards[0].val.should == 5 #and it's in the right order
      hand.hand_cards[3].val.should == 4
      hand.hand_cards[4].val.should == 2
    end
  end

  describe "#two_pair?" do
    it "detects two pair" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(3, :spades)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(4, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.two_pair?.should == true
      hand.hand_cards[0].val.should == 4 #and it's in the right order
      hand.hand_cards[2].val.should == 3
      hand.hand_cards[4].val.should == 6
    end
  end

  describe "#one_pair?" do
    it "detects one pair" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(5, :spades)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(6, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.one_pair?.should == true
      hand.hand_cards[0].val.should == 6 #and it's in the right order
      hand.hand_cards[2].val.should == 5
      hand.hand_cards[3].val.should == 4
      hand.hand_cards[4].val.should == 3
    end
    
    it "detects one pair and puts it in the right order" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(5, :spades)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.one_pair?.should == true
      hand.hand_cards[0].val.should == 5 #and it's in the right order
      hand.hand_cards[2].val.should == 6
      hand.hand_cards[3].val.should == 4
      hand.hand_cards[4].val.should == 3
    end

    it "detects one pair and puts it in the right order" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(4, :spades)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.one_pair?.should == true
      hand.hand_cards[0].val.should == 4 #and it's in the right order
      hand.hand_cards[2].val.should == 6
      hand.hand_cards[3].val.should == 5
      hand.hand_cards[4].val.should == 3
    end

    it "detects one pair and puts it in the right order" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(3, :spades)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.one_pair?.should == true
      hand.hand_cards[0].val.should == 3 #and it's in the right order
      hand.hand_cards[2].val.should == 6
      hand.hand_cards[3].val.should == 5
      hand.hand_cards[4].val.should == 4
    end



  end

  describe "#find_card_combo" do

    it "detects a royal flush hand" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(14, :spades)
      hand.hand_cards[1] = Card.new(13, :spades)
      hand.hand_cards[2] = Card.new(12, :spades)
      hand.hand_cards[3] = Card.new(11, :spades)
      hand.hand_cards[4] = Card.new(10, :spades)
      hand.find_card_combo
      expect(hand.hand_type).to eq(:royal_flush)

    end


    it "detects a one pair" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(3, :spades)
      hand.hand_cards[1] = Card.new(6, :clubs)
      hand.hand_cards[2] = Card.new(3, :clubs)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.find_card_combo
      expect(hand.hand_type).to eq(:one_pair)

    end

    it "detects a high card" do
      hand.new_hand(deck)
      hand.hand_cards[0] = Card.new(14, :spades)
      hand.hand_cards[1] = Card.new(12, :clubs)
      hand.hand_cards[2] = Card.new(2, :diamonds)
      hand.hand_cards[3] = Card.new(5, :hearts)
      hand.hand_cards[4] = Card.new(4, :diamonds)
      hand.find_card_combo
      expect(hand.hand_type).to eq(:high_card)

    end

    it "TEST: find bug!" do
      hand.hand_cards[0] = Card.new(11, :spades)
      hand.hand_cards[1] = Card.new(7, :diamonds)
      hand.hand_cards[2] = Card.new(14, :spades)
      hand.hand_cards[3] = Card.new(11, :diamonds)
      hand.hand_cards[4] = Card.new(14, :diamonds)
      hand.hand_rank

      hand.render.should == "A of diamonds,  A of spades,  J of spades,  J of diamonds,  7 of diamonds, two_pair"

    end

  end
  

end

describe Player do

  subject(:player) do
    Player.new("nat", 100)
  end

  let(:deck) {Deck.new}

  its(:name) {should == "nat"}

  its(:pot) {should == 100}

  it "gets user's input"


end


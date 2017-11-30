class Player
  def initialize(location, items = ItemIterator.new)
    @location = location
    @items = items
  end

  def look_around
    location.describe
    self.class.new(location)
  end

  def pick_up(item)
    self.class.new(location.pick_up(item), items.add(item))
  end

  private

  attr_reader :items
  attr_reader :location
end

class Location
  def initialize(attributes)
    @attributes = attributes
  end

  def describe
    puts description
    items.describe
    self.class.new(attributes)
  end

  def pick_up(item)
    self.class.new(attributes.merge(items: items.remove(item)))
  end

  private

  attr_reader :attributes

  def description
    attributes[:description]
  end

  def items
    attributes[:items]
  end
end

class ItemIterator
  include Enumerable

  def initialize(items = [])
    @items = items
  end

  def describe
    each(&:describe)
    self.class.new(items)
  end

  def add(item)
    self.class.new(items + [item])
  end

  def remove(item)
    self.class.new(items - [item])
  end

  private

  attr_reader :items

  def each
    items.each { |item| yield Item.new(item) }
  end

  class Item
    def initialize(name)
      @name = name
    end

    def describe
      puts "You see a #{name} on the floor."
      self.class.new(name)
    end

    private

    attr_reader :name
  end
end

RSpec.describe Player do
  describe "#look_around" do
    context "when the location has no items" do
      it "prints out the description of the location" do
        description = "You are in a room. A wizard is snoring on the couch."
        items = []
        location = build_location(description: description, items: items)
        player = build_player(location)

        expect do
          player.look_around
        end.to output(<<~"TEXT").to_stdout
          You are in a room. A wizard is snoring on the couch.
        TEXT
      end
    end

    context "when the location has items" do
      it "prints out the description of the location and any items there" do
        description = "You are in a room. A wizard is snoring on the couch."
        items = %w[whiskey bucket]
        location = build_location(description: description, items: items)
        player = build_player(location)

        expect do
          player.look_around
        end.to output(<<~"TEXT").to_stdout
          You are in a room. A wizard is snoring on the couch.
          You see a whiskey on the floor.
          You see a bucket on the floor.
        TEXT
      end
    end
  end

  describe "#pick_up" do
    it "removes an item from the location and adds it to items" do
      description = "You are in a room. A wizard is snoring on the couch."
      items = %w[whiskey bucket]
      location = build_location(description: description, items: items)
      player = build_player(location)

      expect do
        player.look_around.
          pick_up("whiskey").
          look_around
      end.to output(<<~"TEXT").to_stdout
        You are in a room. A wizard is snoring on the couch.
        You see a whiskey on the floor.
        You see a bucket on the floor.
        You are in a room. A wizard is snoring on the couch.
        You see a bucket on the floor.
      TEXT
    end
  end

  private

  def build_player(location)
    Player.new(location)
  end

  def build_location(description: "", items: [])
    Location.new(description: description, items: ItemIterator.new(items))
  end
end

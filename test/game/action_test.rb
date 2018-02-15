require "minitest/autorun"
require "minitest/spec"

require "game/action"

describe Game::Action do
  it "constructs shoot actions" do
    assert Game::Action.shoot(10, Game::Position.new(1, 0)).shoot?
  end

  it "constructs walk actions" do
    assert Game::Action.walk(10, Game::Position.new(1, 0)).walk?
  end

  describe "#from_payload" do
    it "requires a valid 'type' attribute" do
      assert_raises(KeyError) { Game::Action.from_payload(1, {}) }
      assert_raises(KeyError) { Game::Action.from_payload(1, type: Game::Action::SHOOT) }
      assert_raises("Invalid type") { Game::Action.from_payload(1, "type" => "nope") }
    end

    describe "when creating a shoot action" do
      it "requires a direction" do
        assert_raises(KeyError) { Game::Action.from_payload(1, "type" => Game::Action::SHOOT) }

        Game::Action.from_payload(
          1,
          "type" => Game::Action::SHOOT,
          "direction" => [1, 0],
        )
      end
    end
  end
end

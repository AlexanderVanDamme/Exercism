// import exercism/test_runner.{ debug }
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/io.{debug}

pub type Frame {
  Frame(rolls: List(Int), index: Int)
}

pub type Game {
  Game(frames: List(Frame))
}

pub type Error {
  InvalidPinCount
  GameComplete
  GameNotComplete
}

pub fn is_game_already_complete(game: Game) -> Bool {
  10 == list.length(game.frames) && list.all(game.frames, is_frame_complete)
}

pub fn roll(game: Game, knocked_pins: Int) -> Result(Game, Error) {
  debug(game.frames)
  // a knocked_pins amount should always be higher or equal to zero, to 10
  use <- bool.guard(knocked_pins < 0 || knocked_pins > 10,Error(InvalidPinCount))
  // todo: check if game is complete
  use <- bool.guard(is_game_already_complete(game), Error(GameComplete))

  let most_recent_frame = case list.first(game.frames) {
    Ok(last_frame) -> last_frame
    Error(_) -> Frame([], 1)
  }

  let standing_pins_last_frame = case most_recent_frame.index, most_recent_frame.rolls {
    10, [10] -> Ok(10) // a strike in the last frame result in ten standing pins again
    10, [10, 10] -> Ok(10) // two strikes in the last frame result in ten standing pins again
    // two ten throws in last frame results in 10 pins standing again
    10, [10, a] if a + knocked_pins > 10 -> {
        // debug("a: " <> int.to_string(a) <> "   and knocked pins: " <> int.to_string(knocked_pins))
        Error(InvalidPinCount)
      }
      10, [a,b] if a + b == 10 -> Ok(10)  
    _, _ -> Ok(10 - int.sum(most_recent_frame.rolls))
  }

  
  use <- bool.guard(result.is_error(standing_pins_last_frame), Error(InvalidPinCount))

  let was_complete_most_recent_frame = is_frame_complete(most_recent_frame)

  let new_most_recent_frame = case
    knocked_pins,
    was_complete_most_recent_frame,
    standing_pins_last_frame
  {
    knocked_pins, False, Ok(standing_pins_last_frame) if knocked_pins > standing_pins_last_frame 
    -> Error(InvalidPinCount)

    // update the open frame
    knocked_pins, False, _ 
    -> Ok(Frame(..most_recent_frame, rolls: [knocked_pins, ..most_recent_frame.rolls]))
    
    // create a new frame, with index 1 higher
    knocked_pins, True, _ 
    -> Ok(Frame(rolls: [knocked_pins], index: most_recent_frame.index + 1))
  }

  case was_complete_most_recent_frame, new_most_recent_frame {
    False, Ok(frame) -> {
      // remove the last_frame from the game.frames, and add the new_most_recent_frame
      let dropped_frames = list.drop(game.frames, 1)
      Ok(Game(frames: [frame, ..dropped_frames]))
    }
    // update the last frame
    True, Ok(frame) -> Ok(Game(frames: [frame, ..game.frames]))
    // add a new frame
    _, Error(e) -> Error(e)
    // pass the error
  }
}

pub fn is_frame_complete(frame: Frame) -> Bool {
  case frame {
    // after three throws we're always done
    Frame([_, _, _], index: 10) -> True

    // last frame but not all pins were cleared
    Frame([a, b], index: 10) if a + b < 10 -> True
    
    // unless it's the last frame, a player can only throw twice
    Frame([_, _], i) if i < 10 -> True
    
    // a strike not in the last frame
    Frame([10], i) if i < 10 -> True
    
    // in all other cases the frame isn't complete! and the player should throw again to finish the frame
    _ -> False
  }
}

pub fn score(game: Game) -> Result(Int, Error) {
  use <- bool.guard(! is_game_already_complete(game), Error(GameNotComplete))
  // work from index 10 to the start, and hold the two next throws
  


  // check for spares and strikes, and use those next throws

  Ok(score_tail_optimized(game.frames,0, 0, 0))
}

fn score_tail_optimized (frames: List(Frame), score_aggr: Int, _spare_bonus: Int, _strike_bonus: Int) -> Int {
  case frames {
    [] -> score_aggr
    // [10] ->
    // [a,b] ->
    _ -> 300
  }
}

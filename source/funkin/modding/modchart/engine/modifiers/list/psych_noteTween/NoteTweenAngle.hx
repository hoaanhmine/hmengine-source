package funkin.modding.modchart.engine.modifiers.list.psych_noteTween;

import states.PlayState;
import objects.StrumNote;
import funkin.modding.modchart.engine.modifiers.Modifier;
import funkin.modding.modchart.backend.core.ModifierParameters;
import funkin.modding.modchart.backend.core.VisualParameters;

class NoteTweenAngle extends Modifier {

	override public function visuals(data:VisualParameters, params:ModifierParameters):VisualParameters {
		var player = params.player;
		var lane = params.lane;

		var strumNote:StrumNote = getStrumFromInfo(lane, player);

		if (strumNote != null) {
			var currentAngle = strumNote.angle;
			data.angleZ += currentAngle;
		}

		return data;
	}

	override public function shouldRun(params:ModifierParameters):Bool {
		return true;
	}

	private function getStrumFromInfo(lane:Int, player:Int):StrumNote {
		if (PlayState.instance == null) return null;

		var group = player == 0 ? PlayState.instance.opponentStrums : PlayState.instance.playerStrums;
		var strum:StrumNote = null;

		group.forEach(str -> {
			@:privateAccess
			if (str.noteData == lane) {
				strum = str;
			}
		});

		return strum;
	}
}

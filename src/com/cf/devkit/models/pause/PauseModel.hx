package com.cf.devkit.models.pause;

import com.domwires.core.mvc.model.AbstractModel;

@:keep
class PauseModel extends AbstractModel implements IPauseModel
{
    public var state(get, never):EnumValue;

    private var _state:EnumValue = PauseState.UnPaused;

    public function setState(value:EnumValue):IPauseModel
    {
        if (_state != value)
        {
            _state = value;

            dispatchMessage(PauseModelMessageType.PauseStateChanged);
        }

        return this;
    }

    private function get_state():EnumValue
    {
        return _state;
    }
}

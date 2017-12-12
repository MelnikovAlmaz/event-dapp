pragma solidity ^0.4.18;


contract Event{
    // Constant
    uint EVENT_CHANGE_TIME = 3 * 1 days;

    string public _name;
    uint public _creation_time;
    uint public _start_date;
    string public _competence;
    address public _creator;

    mapping(address => uint) public _marks;
    address[] public _participants;
    address[] public _experts;

    address _controller;

    struct Edition{
    string _name;
    uint _start_date;
    string _competence;
    address[] _participants;
    address[] _experts;
    }

    bool public _isEditing;
    uint _acceptanceCount;
    mapping(address => bool) _isExpertAccepted;
    Edition _edition;

    function Event(address creator, string name, uint creation_time, uint start_date, string competence, address[] expert_list, address[] participant_list){
        // Init data of Event
        _name = name;
        _creation_time = creation_time;
        _start_date = start_date;
        _competence = competence;
        _experts = expert_list;
        _participants = participant_list;
        _creator = creator;

        // Edition data Init
        _isEditing = false;
        _acceptanceCount = 0;

        // Init controller contract that can manage event
        _controller = msg.sender;
    }

    function changeMarkOfParticipant(address sender, address participant, uint mark) onlyController public {
        require(isExpert(sender) == true);
        require(isParticipant(participant) == true);

        _marks[participant] = mark;
    }

    function submitAcceptence(address sender) onlyController public returns (bool){
        // Check is editing available
        require(_isEditing);
        if(_creation_time + EVENT_CHANGE_TIME < now){
            closeEventChange();
            return false;
        }
        else{
            // Check is it expert of Event
            require(isExpert(sender));
            require(_isExpertAccepted[sender] == false);

            _isExpertAccepted[sender] = true;
            _acceptanceCount += 1;

            return acceptEdition();
        }
    }

    function changeEvent(address sender, string name, uint start_date, string competence, address[] expert_list, address[] participant_list) onlyController changeAvailable public{
        // Check is it expert of Event
        require(isExpert(sender));
        // Form Event data structure
        _edition = Edition({
        _name: name,
        _start_date: start_date,
        _competence: competence,
        _experts: expert_list,
        _participants: participant_list
        });
        _isEditing = true;
        _acceptanceCount = 1;
        _isExpertAccepted[sender] = true;

        acceptEdition();
    }

    function acceptEdition() private returns (bool){
        // Check if Event has enought aceptance
        if(_experts.length == _acceptanceCount){
            // Add edition to Event
            _name = _edition._name;
            _start_date = _edition._start_date;
            _competence = _edition._competence;
            _experts = _edition._experts;
            _participants = _edition._participants;

            closeEventChange();
            return true;
        }
        else {
            return false;
        }
    }

    function closeEventChange() private {
        // Delete all experts votes
        for(uint i=0;i<_experts.length;i++){
            _isExpertAccepted[_experts[i]] = false;
        }
        _acceptanceCount = 0;
        _isEditing = false;
    }

    function isExpert(address sender) private returns (bool){
        bool is_expert = false;
        for(uint i=0;i<_experts.length;i++){
            if(_experts[i] == sender){
                is_expert = true;
                break;
            }
        }
        return is_expert;
    }

    function isParticipant(address sender) private returns (bool){
        bool is_participant = false;
        for(uint i=0;i<_participants.length;i++){
            if(_participants[i] == sender){
                is_participant = true;
                break;
            }
        }
        return is_participant;
    }

    modifier onlyController {
        require(msg.sender == _controller);
        _;
    }

    modifier changeAvailable {
        require(_isEditing == false);
        require(_acceptanceCount == 0);
        for(uint i=0;i<_experts.length;i++){
            require(_isExpertAccepted[_experts[i]] == false);
        }
        _;
    }
}
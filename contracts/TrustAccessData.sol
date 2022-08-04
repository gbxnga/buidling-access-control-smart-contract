pragma solidity ^0.8.13;

contract TrustAccessData {

    address private contactOwner;
    bool private operational = true;

    uint public apartmentCount; 
    uint public residentCount; 
    uint public appointmentCount; 

    constructor() {
        contactOwner = msg.sender;
    }

    mapping(address => Apartment) public apartments;
    mapping(address => Resident) public residents;

    // (_residentAddress => _apartmentAddress[])
    mapping(address => address[]) public residentToApartmentsMap;

    mapping(bytes32 => Appointment) public appointments;


    event ApartmentRegistered(
        address _apartmentAddress, 
        string _name 
    );
    event ResidentRegistered( 
        address _residentAddress, 
        string _name 
    );
    event AppointmentMade ( 
        bytes32 appointmentId, 
        address _residentAddress,
        address _apartmentAddress,
        address _visitorAddress, 
        string _time 
    );
    event ResidentAssignedToApartment(
        address _residentAddress,
        address _apartmentAddress
    );


    modifier apartmentExists(address _apartmentAddress) {
        require(apartments[_apartmentAddress].isValue, "Apartment with address doesnt exist");
        _;
    }

    modifier apartmentDoesntExist(address _apartmentAddress) {
        require(!apartments[_apartmentAddress].isValue, "Apartment with address already exist");
        _;
    }

    modifier residentExists( address _residentAddress ) {
        require(residents[_residentAddress].isValue, "Resident with address doesnt exists");
        _;
    }

    modifier residentDoesntExist( address _residentAddress ) {
        require(!residents[_residentAddress].isValue, "Resident with address already exists");
        _;
    }

    modifier isSender( address _receivedSenderAddress ) {
        require(_receivedSenderAddress == msg.sender, "Received address must be equal to sender address");
        _;
    }

    modifier apartmentBelongsToResident(
        address _residentAddress, 
        address _apartmentAddress
    ) {
        address[] memory apartmentsBelongingToResident = residentToApartmentsMap[_residentAddress];
        bool apartmentFound = false; 
      


        for(uint8 i=0;i < apartmentsBelongingToResident.length;){
            if(apartmentsBelongingToResident[i] == _apartmentAddress){
                apartmentFound = true;
                break;
            }

            unchecked {
                ++i;
            }
        }
        require(apartmentFound, "Apartment doesnt to belong to resident");
        _;
    }
     
    function numberOfResidents()
        external
        view
        returns (uint)
    {
        return residentCount;
    }

    function numberOfApartments()
        external
        view
        returns (uint)
    {
        return apartmentCount;
    }

    function fetchApartment( address _apartmentAddress )
        public
        view
        apartmentExists( _apartmentAddress )
        returns(
            uint id,
            ApartmentStatus status,
            string memory name
        )
    {
        id = apartments[_apartmentAddress].id;
        status = apartments[_apartmentAddress].status;
        name = apartments[_apartmentAddress].name;

        return(
            id,
            status,
            name
        );
    }

    function registerApartment( 
        address _apartmentAddress, 
        string memory _name 
    ) 
        public 
        apartmentDoesntExist(_apartmentAddress)
        returns(Apartment memory apartment)
    {

        apartments[_apartmentAddress].id = apartmentCount;
        apartments[_apartmentAddress].name = _name;
        apartments[_apartmentAddress].status = ApartmentStatus.Active;
        apartments[_apartmentAddress].isValue = true;

        apartmentCount = apartmentCount + 1;

        emit ApartmentRegistered(_apartmentAddress, _name);

        return apartments[_apartmentAddress];
    }

    function fetchResident( address _residentAddress )
        public
        view
        residentExists(_residentAddress)
        returns(
            uint id,
            string memory name,
            bool isActive
        )
    {
        id = residents[_residentAddress].id;
        name = residents[_residentAddress].name;
        isActive = residents[_residentAddress].isActive;

        return(
            id,
            name,
            isActive
        );
    }

    function registerResident( 
        address _residentAddress, 
        string memory _name 
    ) 
        public 
        residentDoesntExist(_residentAddress)
        returns(Resident memory resident)
    { 

        residents[_residentAddress].id = residentCount;
        residents[_residentAddress].name = _name;
        residents[_residentAddress].isActive = true;
        residents[_residentAddress].isValue = true;

        residentCount = residentCount + 1;

        emit ResidentRegistered(_residentAddress, _name);

        return residents[_residentAddress];
    }

    function fetchResidentApartments(address _residentAddress)
        public
        view
        residentExists( _residentAddress )
        returns(
            address[] memory residentApartments
        )
    {
        return residentToApartmentsMap[_residentAddress];
    }

    function assignResidentToApartment ( 
        address _residentAddress, 
        address _apartmentAddress 
    )
        public
        residentExists( _residentAddress )
        apartmentExists( _apartmentAddress )
        returns(address[] memory residentApartments)
    {  

        residentToApartmentsMap[_residentAddress].push(_apartmentAddress);

        emit ResidentAssignedToApartment(
            _residentAddress,
            _apartmentAddress
        );

        return residentToApartmentsMap[_residentAddress];
    }

    function makeAppointment(  
        address _apartmentAddress, 
        address _visitorAddress, 
        string memory _time
    )
        public
        residentExists( msg.sender )
        apartmentExists( _apartmentAddress )
        apartmentBelongsToResident( msg.sender , _apartmentAddress )
         
        returns(bytes32 _appointmentId, string memory time )
    { 

        bytes32 appointmentId = keccak256(
            abi.encode( 
                _apartmentAddress,
                _visitorAddress,
                _time
            )
        );

        Appointment storage appointment = appointments[appointmentId];

        appointment.id = appointmentId;
        appointment.residentAddress =  msg.sender;
        appointment.apartmentAddress =  _apartmentAddress ;
        appointment.visitorAddress =  _visitorAddress;
        appointment.status =  AppointmentStatus.Active;
        appointment.time = _time; 
        appointment.isValue = true;

        appointmentCount++;

        require(appointments[appointmentId].isValue, "Appoint was not created");

        emit AppointmentMade( 
            appointmentId,
            msg.sender,
            _apartmentAddress,
            _visitorAddress, 
            _time
        );
 

        return (appointmentId, _time);
    }

    function verifyAppointment( 
        address _visitorAddress,
        string memory _time,
        address _apartmentAddress
    )
        public
        view
        residentExists( msg.sender )
        returns (bool valid)
    { 
        bytes32 appointmentId = keccak256(
            abi.encode( 
                _apartmentAddress,
                _visitorAddress,
                _time
            )
        );

        // require(appointments[_appointmentId].isValue, "Appointment does not exist");
        Appointment storage appointment = appointments[appointmentId];

        return  appointment.visitorAddress == _visitorAddress;
    }

    enum ApartmentStatus { 
        Inactive,
        Active,
        Suspended
    }

    enum AppointmentStatus { 
        Inactive,
        Active,
        CheckedIn,
        CheckedOut
    }

    enum ApartmentResidentsStatus {
        Inactive,
        Active
    }

    struct Apartment {
        uint id;
        ApartmentStatus status;
        address apartment;
        string name; 
        bool isValue;
    }

    struct Resident {
        uint id;
        string name;
        bool isActive;
        bool isValue;
    }

    struct ApartmentResidents {
        address apartmentAddress;
        address residentAddress;
        ApartmentResidentsStatus status; 
    }

    struct Appointment {
        bytes32 id;
        address residentAddress;
        address apartmentAddress;
        address visitorAddress;
        AppointmentStatus status;
        string time; 
        bool isValue;
    }
}
pragma solidity ^0.8.13;

contract TrustAccessData {

    address private contactOwner;
    bool private operational = true;

    uint apartmentCount; 
    uint residentCount; 
    uint appointmentCount; 

    constructor() {
        contactOwner = msg.sender;
    }

    mapping(address => Apartment) public apartments;
    mapping(address => Resident) public residents;

    // (_residentAddress => _apartmentAddress)
    mapping(address => uint[]) public residentToApartmentsMap;

    mapping(uint => Appointment) public appointments;


    event ApartmentRegistered(
        address _apartmentAddress, 
        string _name 
    );
    event ResidentRegistered( 
        address _residentAddress, 
        string _name 
    );
    event AppointmentMade (
        address _residentAddress, 
        address _apartmentAddress, 
        address _visitorAddress, 
        string startTime, 
        string endTime 
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

    modifier apartmentBelongsToResident(
        address _residentAddress, 
        address _apartmentAddress
    ) {
        uint[] memory apartmentsBelongingToResident = residentToApartmentsMap[_residentAddress];
        bool apartmentFound = false;
        uint apartmentId = apartments[_apartmentAddress].id;
        uint i;


        for(i=0;i < apartmentsBelongingToResident.length; i++){
            if(apartmentsBelongingToResident[i] == apartmentId){
                apartmentFound = true;
                break;
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
            uint[] memory residentApartments
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
        returns(uint[] memory residentApartments)
    { 
        Apartment memory apartment = apartments[_apartmentAddress];

        residentToApartmentsMap[_residentAddress].push(apartment.id);

        emit ResidentAssignedToApartment(
            _residentAddress,
            _apartmentAddress
        );

        return residentToApartmentsMap[_residentAddress];
    }

    function makeAppointment( 
        address _residentAddress, 
        address _apartmentAddress, 
        address _visitorAddress, 
        string memory _startTime, 
        string memory _endTime 
    )
        public
        residentExists( _residentAddress )
        apartmentExists( _apartmentAddress )
        apartmentBelongsToResident( _residentAddress, _apartmentAddress )
        returns(bool success)
    {

        Apartment memory apartment = apartments[_apartmentAddress];

        appointments[appointmentCount].residentAddress =  _residentAddress;
        appointments[appointmentCount].apartmentId =  apartment.id;
        appointments[appointmentCount].visitorAddress =  _visitorAddress;
        appointments[appointmentCount].status =  AppointmentStatus.Active;
        appointments[appointmentCount].startTime = _startTime;
        appointments[appointmentCount].endTime = _endTime;

        emit AppointmentMade(
            _residentAddress, 
            _apartmentAddress, 
            _visitorAddress, 
            _startTime, 
            _endTime 
        );

        return true;
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
        address residentAddress;
        uint apartmentId;
        address visitorAddress;
        AppointmentStatus status;
        string startTime;
        string endTime;
    }
}
//Get user
import 'package:graphql_flutter/graphql_flutter.dart';

String getMe = """
    query getMe {
      me {
      id
      uid
      name
      email    
      userType
      isPartnerRegistered
      isCustomerRegistered
      phone
      partnerDetails {
        id
        approved
        isZimkeyPartner
        disableAccount
        aadharNumber
        unavailableTill
        walletLogs {
          id
          transactionDate
          logType
          source
          refId
          amount
          transferRef
        }
        walletBalance
        pendingTasks
        isAvailable
        ifsc
        accountNumber    
        address{
          id
          buildingName
          buildingNumber
          locality
          landmark
          area
          address
          postalCode
        }
        documents{
          id
          medias{
            id
            url
          }
          documentType
        }    
        company{
          id
          companyName
        }
        photo {
          id
          url
          type
          enabled
        }      
        serviceAreas {
          id
          name
          pinCodes {
            pinCode
          }
        }
        services {
          id
          name
        }
      }
    }
  }
  """
    .replaceAll('\n', '');

//Register partner details
String registerPartner = '''
mutation registerPartner(
  \$data: PartnerRegisterGqlInput!){
  registerPartner(data: \$data) 
  {
    id  
    isPartnerRegistered
    userType
  } 
}
'''
    .replaceAll('\n', '');

String login = '''
mutation sendOtp(
  \$data: UserSendOtpGqlInput!){
  sendOtp(data: \$data){
        status
        message
    } 
  
}
'''
    .replaceAll('\n', '');
String verifyOtp = '''
mutation verifyOtp(
  \$data: UserVerifyOtpGqlInput!){
  verifyOtp(data: \$data) {
        status
        message
        data {
            isPartnerRegistered
            token
            user {
                id
                name
                phone
                email
            }
        }
    } 
  
}
'''
    .replaceAll('\n', '');

//Select Partner services
String updatePartnerServices = '''
mutation updatePartnerServices(\$services:[String!]!){
  updatePartnerServices(services: \$services) {
    id
  }
}
'''
    .replaceAll('\n', '');

//Get areas list
String getAreas = '''
  query getAreas {
    getAreas {
      id
      name
      code    
      pinCodes {
        id
        areaId
        pinCode
      }
    }
  }
 '''
    .replaceAll('\n', '');

//get ServiceList
String getServiceCategories = '''
  query getServiceCategories {
    getServiceCategories {
      id
      name
      code
      code
      images {
        url
        id
      }
      services {
        id
        icon {
          id
          url
          name
        }
        addons {
          id
          name
          description
          serviceId
          unit
          maxUnit
          minUnit          
        }
        billingOptions {
          id
          code
          description
          name
          recurring
          recurringPeriod
          autoAssignPartner
          maxUnit
          minUnit
          unit
        }
        name
        description
        requirements {
          id
          description
          title
        }
        medias {
          id
          thumbnail {
            id
            url
          }
          url
        }
        inputs {
          id
          name
          description
          key
          type
        }        
      }
    }
  }
  '''
    .replaceAll('\n', '');

//Update service categories
String updatePartnerCategories = '''
mutation updatePartnerCategories (\$categories: [String]!){
  updatePartnerCategories({categories: \$categories   
 }) {
    id
    name
    partnerDetails{
      categorySelected
      serviceAreaSelected
    }
  }
}
 '''
    .replaceAll('\n', '');

//Update partner documents
String updatePartnerDocument = '''
mutation updatePartnerDocument(\$type: DocumentTypeEnum!, \$medias: [String!]!){
  updatePartnerDocument(
    document: { 
      type: \$type, 
      medias: \$medias
  }) {
    id
    name   
  }
}
'''
    .replaceAll('\n', '');

//Update Partner Service Areas
String updatePartnerAreas = '''
mutation updatePartnerAreas(\$areas :[String!]!){
  updatePartnerAreas(areas: \$areas){
    id
  }
}
'''
    .replaceAll('\n', '');

//Get job board
String getJobBoard = '''
query getJobBoard(\$pageSize: Int, \$pageNumber: Int){
  getJobBoard(pagination: {pageNumber: \$pageNumber, pageSize: \$pageSize}) {
        data {
            id
            jobDate
            addedDate
        
            jobArea{
                name
                id
            }
            jobService{
                name
                icon{
                    url
                }
                isTeamService
            }
           
            bookingId
            bookingServiceId
            bookingService{
                service{
                    icon{
                        url
                    }
                }
            }
            bookingServiceItemId
            jobPriority
          
        }
           pageInfo {
            hasNextPage
            currentPage
            currentCount
            nextPage
            totalPage
            totalCount
        }
    }
}
'''
    .replaceAll('\n', '');

String getDashBoard = '''
query getPartnerDashboard {
    getPartnerDashboard {
        assigned_jobs
        completed_jobs
        in_progress
        wallet_balance
        pending_jobs
        cancelled_jobs
    }
}'''
    .replaceAll('\n', '');

String getCalenerShort = '''
    query getPartnerCalendarItems(\$pageSize: Int, \$pageNumber: Int, \$status: PartnerBookingsStatusTypeEnum) {
  getPartnerCalendarItems(
    pagination: {
      pageSize: \$pageSize
      pageNumber: \$pageNumber
    }
    filter: {
      status: \$status
    }
  ) {
    data {
      id
      serviceDate
      partnerCalendarStatus
      booking {
        userBookingNumber
           bookingPayments {
            id
            orderId
            paymentId
            amount
            amountPaid
            amountDue
            currency
            status
            attempts
            invoiceNumber
            bookingId
          }
        bookingStatus
        bookingService {
        serviceBillingOptionId
          service {
            name
             icon {
                id
                url
                name
              }
              requirements {
                id
                description
                title
              }
              billingOptions {
                name
                id
              }
              
          }
          
        }
        bookingAddress {
          area {
            name
          }
        }
      }
      bookingServiceItem {
      units
        bookingServiceItemType
        bookingServiceItemStatus
        actualEndDateTime
        startDateTime
        chargedPrice {
            grandTotal
        }

      }
    }
    pageInfo {
      hasNextPage
      currentPage
      currentCount
      nextPage
      totalPage
      totalCount
    }
  }
}

'''
    .replaceAll('\n', '');
//Get Partner calendar items
String getPartnerCalendar = '''query getPartnerCalendarItem(\$id:ID!){
  getPartnerCalendarItem(id:\$id
      )  {
        id
        partnerCalendarStatus
        partnerNote
        serviceDate
        bookingId    
        teams{
            id
            name
        }  

        bookingServiceItemId  
        bookingServiceItem {
        chargedPrice {
            grandTotal
        }
        units
          bookingServiceId
          refBookingServiceItem {
                activePartnerCalenderId
}
          bookingServiceItemType
          actualStartDateTime
          startDateTime
          endDateTime
          bookingServiceItemStatus
          id      
          canReschedule
                 additionalWorks {
                 
                modificationReason
                
                bookingAdditionalWorkStatus
            bookingAddons {
                name
                units
                unit
                amount {
                    grandTotal
                }
            }
            additionalHoursUnits
            additionalHoursAmount {
                grandTotal
            }
            totalAdditionalWorkAmount {
                grandTotal
            }
            isPaid
        }
        pendingRescheduleByCustomer{
          startDateTime
          endDateTime
          }
          canUncommit
          canStartJob
          workCode
          reschedules {
            rescheduledBy
            oldTime
          }
          modificationReason
          subBookings {
            id
            bookingServiceItemType
            modificationReason
            startDateTime
            bookingServiceItemStatus          
            bookingService {  
              bookingAdditionalPayments {
                id
                itemPrice {
                  commission
                  commissionTax
                  partnerTax
                  partnerPrice
                }
                name
                description
                refundable
                refundAmount
                mandatory
                bookingServiceId
              }
              service {
                name
              }
            }
          }
          bookingAddons {
            name
            unit
            units
            itemPrice {
              commission
              commissionTax
              partnerTax
              partnerPrice
            }
            addedBy
            addonId
            bookingServiceItemId
          }  
          servicePartnerId
          bookingService {
            id
            recurring
           serviceBillingOption {
                additionalMinUnit
                additionalMaxUnit
            }
            serviceBillingOptionId
            unit
            serviceRequirements 
            service {
              name         
              icon {
                id
                url
                name
              }   
              billingOptions {
                id
                code
                minUnit
                maxUnit
                additionalMinUnit
                unit
                unitPrice {
                  commission
                }
                recurring
                recurringPeriod
                additionalUnitPrice{
                  total
                }
              }
              addons {
                id
                name
                description
                serviceId
                unit
                unitPrice {
                  partnerTax
                  partnerPrice
                  commission
                  commissionTax
                  total
                }
                maxUnit
                minUnit                
                type
              }
            }
            bookingAdditionalPayments {
              id
              itemPrice {
                commission
                commissionTax
                partnerTax
                partnerPrice
              }
              name
              description
              refundable
              mandatory
              bookingServiceId
            }
          }
        }
        booking {
          userBookingNumber
          bookingPayments {
            id
            orderId
            paymentId
            amount
            amountPaid
            amountDue
            currency
            status
            attempts
            invoiceNumber
            bookingId
          }
          bookingAmount {
            totalDiscount
            totalPartnerAmount
            totalCommission
            commissionGSTAmount
            partnerGSTAmount
            totalDiscount
            totalRefundable
            totalRefunded
          }
          pendingAmount{
            amount
          }
          bookingNote
          bookingStatus
          user {
            name
            phone
          }
          appliedCoupons
          bookingService {
            serviceId
            serviceRequirements
            bookingServiceInputs {
              bookingServiceId
              name              
            }
            serviceBillingOptionId
            service {
              name
              icon {
                id
                url
                name
              }
              requirements {
                id
                description
                title
              }
              billingOptions {
                name
                id
              }
            }
         
          }
          bookingAddress {
            addressType    
            areaId
            area {
              name
              id
            }
            locality
            landmark
            postalCode
            buildingName
          }
        }
    }
}
'''
    .replaceAll('\n', '');

//Assign Job to Partner
String commitJob = '''
mutation commitJob(\$jobBoardId: String!,\$teamId:[String!]){
  commitJob(jobBoardId: \$jobBoardId,teamId:\$teamId) {
    id
    partner {
      id
    }    
    partnerId
  }
}
'''
    .replaceAll('\n', '');

//Start A Job
String startJob = '''
mutation startJob(\$bookingServiceItemId: ID!, \$workCode: String!){
  startJob(
    bookingServiceItemId: \$bookingServiceItemId, 
    workCode: \$workCode) {
    id
  }
}
'''
    .replaceAll('\n', '');
String rework = '''
mutation ApproveReworkJob(\$bookingServiceItemId: ID!, \$status: Boolean!){
    approveReworkJob(bookingServiceItemId: \$bookingServiceItemId, status: \$status)
}

'''
    .replaceAll('\n', '');

//Finish A Job
String finishJob = '''
mutation finishJob(\$bookingServiceItemId: ID!,  \$note : String!){
  finishJob(bookingServiceItemId: \$bookingServiceItemId, 

  note: \$note,
  ){
    id
  }
}
'''
    .replaceAll('\n', '');

//Finish A Job
String uncommitJob = '''
mutation uncommitJob(\$bookingServiceItemId : ID!){
  uncommitJob(bookingServiceItemId: \$bookingServiceItemId) {
    id
  }
}
'''
    .replaceAll('\n', '');

//Reschdeule A Job
String rescheduleJob = '''
mutation RescheduleJob(\$scheduleTime: DateTime!, \$bookingServiceItemId: ID!, \$modificationReason: String){
  rescheduleJob(scheduleTime: \$scheduleTime,
    bookingServiceItemId:  \$bookingServiceItemId,
    scheduleEndDateTime: \$scheduleTime,
    modificationReason: \$modificationReason){
        id
        bookingServiceId
        units
        workCode
        jobRating
        modificationReason
        bookingServiceItemType
        bookingServiceItemStatus
        servicePartnerId
        activePartnerCalenderId
        canRework
        canCancel
        canReschedule
        canUncommit
        startDateTime
        endDateTime
        otherRequirements
    }
}
'''
    .replaceAll('\n', '');

String changeTeam = '''
mutation changeJobTeam(\$partnerCalendarId: String!, \$teamIds: [String!]!){
  changeJobTeam(
    partnerCalendarId: \$partnerCalendarId,
    teamIds: \$teamIds
  
  ) {
        id
        partnerCalendarStatus
        serviceDate
        partnerId
        bookingId
        bookingServiceItemId
        adminNote
        partnerNote
        teams {
            id
            name
            members {
                name
            }
        }
    }
}
'''
    .replaceAll('\n', '');

//Fetch booking time slots
String getTimeSlots = '''
query getServiceBookingSlots(\$date: DateTime!, \$billingOptionId: String!, \$partnerId: String,\$isReschedule:Boolean,\$bookingServiceItemId:String){
  getServiceBookingSlots(
    date: \$date,
    billingOptionId: \$billingOptionId
    partnerId: \$partnerId
   isReschedule:\$isReschedule
    bookingServiceItemId:\$bookingServiceItemId
  ) {
    start
    end
    available
  }
}
 '''
    .replaceAll('\n', '');

//Add Addons
String addAddon = '''
mutation addAddon(\$units: Float!,\$addonId: ID!, \$bookingServiceItemId: ID!){
  addAddon(
    units: \$units,
    bookingServiceItemId: \$bookingServiceItemId, 
    addonId: \$addonId
  ){
    id
  }
}
 '''
    .replaceAll('\n', '');

//Add Additional work
String addAdditionalWork = '''
mutation addAdditionalWork(
   \$addons: [BookingServiceAddonGqlInput!],
   \$startDateTime: DateTime,
   \$endDateTime: DateTime,
   \$units: Float!,
   \$bookingServiceItemId: ID!,
   \$modificationReason: String
){
  addAdditionalWork(
    addons: \$addons
    startDateTime: \$startDateTime
    endDateTime:\$endDateTime
    units: \$units
    bookingServiceItemId: \$bookingServiceItemId
    modificationReason: \$modificationReason
  ) {
        id
        bookingServiceItemId
        bookingServiceItem {
            id
            bookingServiceItemStatus
        }
        modificationReason
        bookingAdditionalWorkStatus
        additionalHoursItemPrice {
            unitPrice
            partnerPrice
            commission
            commissionTax
            partnerTax
            totalTax
            commissionAmount
            commissionTotal
            partnerTotal
            grandTotal
            total
        }
        additionalHoursUnits
        unit
        minUnit
        maxUnit
        additionalHoursAmount {
            unitPrice
            partnerRate
            partnerDiscount
            partnerAmount
            partnerGSTPercentage
            partnerGSTAmount
            totalPartnerAmount
            commissionPercentage
            commissionRate
            commissionDiscount
            commissionAmount
            commissionGSTPercentage
            commissionGSTAmount
            totalCommission
            subTotal
            totalDiscount
            totalAmount
            totalGSTAmount
            grandTotal
            totalRefundable
            totalRefunded
        }
        bookingAddons {
            name
            units
            unit
            minUnit
            maxUnit
            addedBy
            addonId
            bookingServiceItemId
        }
        totalAdditionalWorkAmount {
            subTotal
            totalDiscount
            totalAmount
            totalGSTAmount
            grandTotal
        }
        isPaid
    }
}
  '''
    .replaceAll('\n', '');

//set FCM Token for push notification
String registerFcmToken = '''
mutation registerFcmToken(\$device: DeviceTypeEnum!,\$deviceId: String!, \$token: String!){
  registerFcmToken(
    data: { 
      device: \$device, 
      deviceId: \$deviceId, 
      token: \$token,
      app: PARTNER
    })
}
'''
    .replaceAll('\n', '');

//Unregister FCM token
String unregisterFcmToken = '''
mutation unregisterFcmToken(\$deviceId: String!) {
  unregisterFcmToken(deviceId: \$deviceId)
}
'''
    .replaceAll('\n', '');

//Update Partner Details
String updatePartnerDetails = '''
mutation updatePartnerDetails(
  \$name : String, 
  \$address: PartnerRegisterAddressGqlInput, 
  \$email: String, 
  \$photoId: String
  \$companyId: String
  \$aadharNumber :String
  ){
  updatePartnerDetails(data:{
    name: \$name,
    address: \$address,
    email: \$email,
    photoId: \$photoId,
    companyId: \$companyId
    aadharNumber :\$aadharNumber
  }){
    id
  }
}
'''
    .replaceAll('\n', '');

//Approve Pending Job
String approveJob = '''
mutation approveJob(
  \$bookingServiceItemId : ID!,\$status:Boolean!
){
  approveJob(
    bookingServiceItemId: \$bookingServiceItemId
    status:\$status
    
    ){
    id
  }
}
'''
    .replaceAll('\n', '');

//Update Payout Account Details
String updatePartnerPayoutAccount = '''
mutation updatePartnerPayoutAccount(\$data: PartnerUpdatePayoutGqlInput!){
  updatePartnerPayoutAccount(
    data: \$data
  ) {
    id
  }
}
'''
    .replaceAll('\n', '');

//Get CMS content
String getCmsContent = '''
  query getCmsContent {
    getCmsContent {
      id
      aboutUs
      referPolicy
      termsConditionsPartner
      privacyPolicy
      safetyPolicy
    }
  }
  '''
    .replaceAll('\n', '');

//Get Partner Companies
String getPartnerCompanies = '''
query getPartnerCompanies(\$pageNumber:Int,\$pageSize:Int,\$companyName:String) {
  getPartnerCompanies(
    pagination: {  
       pageSize: \$pageSize
        pageNumber: \$pageNumber
        }
    filters: { companyName: \$companyName }
  ) {
    data {
      id
      companyName
      companyAddress
    }
  }
}
  '''
    .replaceAll('\n', '');

//Mutation Upadte partner unavailability
String updatePartnerUnavailable = '''
mutation updatePartnerUnavailable( \$unavailableTill : DateTime){
  updatePartnerUnavailable(
    unavailableTill: \$unavailableTill) {
    id
  }
}
 '''
    .replaceAll('\n', '');

//Mutation partner Redeem Wallet
String partnerRedeemWallet = '''
mutation partnerRedeemWallet(\$amount: Float!){
  partnerRedeemWallet(
    amount: \$amount)
}
 '''
    .replaceAll('\n', '');

String addCustomerSupport = '''
mutation AddCustomerSupport(\$subject:String!,\$message:String!) {
    addCustomerSupport(data: {subject: \$subject, message: \$message}) {
        id
        userId
        subject
        message
        createDateTime
    }
}
 '''
    .replaceAll('\n', '');

//Get Call from Partner
String callPartnerCustomer = '''
mutation callPartnerCustomer(\$bookingServiceItemId: String!){
  callPartnerCustomer(bookingServiceItemId: \$bookingServiceItemId)
}
 '''
    .replaceAll('\n', '');

//Get Banners images
String getBanners = '''
 query getBanners(\$getAll: Boolean){
  getBanners(
    getAll: \$getAll
  ){
    id
    title
    description
    url
    mediaId
    media{
      id
      url
    }
  }
}
'''
    .replaceAll('\n', '');

String getTeams = '''query getTeams(\$pageNumber:int, \$pageSize:int){
    getTeams(
        filters: {}
        pagination: { pageNumber: \$pageNumber, pageSize: \$pageSize }
    ) {
        data {
            id
            uid
            name
            partnerId
            strength
            members {
                id
                name
                uid
                phone
                rank
                isActive
            }
            isActive
            partner {
                id
                name
                email
                phone
                dob
                gender
                uid
            }
        }
    }
}
'''
    .replaceAll('\n', '');

FetchMoreOptions buildFetchMoreOptions(QueryResult result, int page) {
  return FetchMoreOptions(
    variables: {
      "pageSize": 20,
      "pageNumber": page,
    },
    updateQuery: (Map<String, dynamic>? previousResultData,
        Map<String, dynamic>? fetchMoreResultData) {},
  );
}

enum PartnerBookingsStatusTypeEnum { OPEN, IN_PROGRESS, COMPLETED }

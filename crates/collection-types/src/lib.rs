//! Shared inputs for two school-collection acceptance rules.

/// An account identifier supplied by the surrounding authentication system.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct AccountId(pub u64);
/// A school child identifier.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ChildId(pub u64);
/// A collector identifier.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct CollectorId(pub u64);
/// An opaque day identifier; calendar conversion is outside this example.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Day(pub u64);
/// A school-recorded permission; presence does not establish actual authority.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct RecordedAuthorisation {
    /// Account recorded as permitted to approve collection.
    pub account: AccountId,
    /// Child for whom the recorded permission applies.
    pub child: ChildId,
}
/// State supplied by the school and authentication system.
pub struct SchoolState {
    /// Accounts authenticated as parent accounts by the surrounding system.
    pub signed_in_parents: Vec<AccountId>,
    /// Recorded account–child permissions, which may be inaccurate.
    pub recorded_authorisations: Vec<RecordedAuthorisation>,
    /// The current day supplied by the surrounding system.
    pub today: Day,
}
/// The collection being requested.
pub struct Request {
    /// Child to collect.
    pub child: ChildId,
    /// Person collecting the child.
    pub collector: CollectorId,
    /// Requested collection day.
    pub day: Day,
}
/// Approval supplied for a collection request.
pub struct Approval {
    /// Account providing approval.
    pub approver: AccountId,
    /// Child named in the approval.
    pub child: ChildId,
    /// Collector named in the approval.
    pub collector: CollectorId,
    /// Day named in the approval.
    pub day: Day,
}

//! The fixed acceptance rule: checks details and child-specific recorded authority.
use collection_types::{Approval, RecordedAuthorisation, Request, SchoolState};

/// Accepts matching details only when the school records authorise the approver.
/// This checks recorded permission, not the accuracy of the school's records.
/// The caller must authenticate approval provenance and supply session and day data.
/// Evaluates in O(n + m) time for n signed-in accounts and m permission records,
/// with no allocation. These illustrative lists have no enforced size bound.
///
/// # Example
/// ```
/// use collection_types::{AccountId, Approval, ChildId, CollectorId, Day, RecordedAuthorisation, Request, SchoolState};
/// let state = SchoolState {
///     signed_in_parents: vec![AccountId(1), AccountId(2)],
///     recorded_authorisations: vec![RecordedAuthorisation { account: AccountId(1), child: ChildId(10) }],
///     today: Day(42),
/// };
/// let request = Request { child: ChildId(10), collector: CollectorId(2), day: Day(42) };
/// let eve = Approval { approver: AccountId(2), child: ChildId(10), collector: CollectorId(2), day: Day(42) };
/// assert!(!child_authorisation::accepts(&state, &request, &eve));
/// let alice = Approval { approver: AccountId(1), ..eve };
/// assert!(child_authorisation::accepts(&state, &request, &alice));
/// ```
#[must_use]
pub fn accepts(state: &SchoolState, request: &Request, approval: &Approval) -> bool {
    collection_details::accepts(state, request, approval)
        && state
            .recorded_authorisations
            .contains(&RecordedAuthorisation {
                account: approval.approver,
                child: request.child,
            })
}

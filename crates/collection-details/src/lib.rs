//! Checks supplied signed-in-parent membership, matching details and day.
//! This intentionally incomplete rule does not check child-specific authority.
use collection_types::{Approval, Request, SchoolState};

/// Accepts matching, current-day details from a signed-in parent account.
/// Acceptance does not establish authority over the requested child.
/// The caller must authenticate approval provenance and supply session and day data.
/// Evaluates in O(n) time for n signed-in accounts, with no allocation.
///
/// # Example
/// ```
/// use collection_types::{AccountId, Approval, ChildId, CollectorId, Day, Request, SchoolState};
/// let state = SchoolState {
///     signed_in_parents: vec![AccountId(2)],
///     recorded_authorisations: vec![],
///     today: Day(42),
/// };
/// let request = Request { child: ChildId(10), collector: CollectorId(2), day: Day(42) };
/// let approval = Approval { approver: AccountId(2), child: ChildId(10), collector: CollectorId(2), day: Day(42) };
/// // Matching details suffice here, even without recorded authority.
/// assert!(collection_details::accepts(&state, &request, &approval));
/// ```
#[must_use]
pub fn accepts(state: &SchoolState, request: &Request, approval: &Approval) -> bool {
    state.signed_in_parents.contains(&approval.approver)
        && approval.child == request.child
        && approval.collector == request.collector
        && approval.day == request.day
        && request.day == state.today
}

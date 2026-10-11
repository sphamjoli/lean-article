//! Run the same collection request against both rules and two record sets.
use collection_types::{
    AccountId, Approval, ChildId, CollectorId, Day, RecordedAuthorisation, Request, SchoolState,
};

fn main() {
    let mut state = SchoolState {
        signed_in_parents: vec![AccountId(2)],
        recorded_authorisations: vec![
            RecordedAuthorisation {
                account: AccountId(1),
                child: ChildId(10),
            },
            RecordedAuthorisation {
                account: AccountId(2),
                child: ChildId(20),
            },
        ],
        today: Day(42),
    };
    let request = Request {
        child: ChildId(10),
        collector: CollectorId(2),
        day: Day(42),
    };
    let approval = Approval {
        approver: AccountId(2),
        child: ChildId(10),
        collector: CollectorId(2),
        day: Day(42),
    };
    println!(
        "Eve approves Charlie: details={}, authorisation={}",
        collection_details::accepts(&state, &request, &approval),
        child_authorisation::accepts(&state, &request, &approval)
    );
    state.signed_in_parents.push(AccountId(1));
    let alice_approval = Approval {
        approver: AccountId(1),
        ..approval
    };
    println!(
        "Alice approves Charlie: authorisation={}",
        child_authorisation::accepts(&state, &request, &alice_approval)
    );
    state.recorded_authorisations.push(RecordedAuthorisation {
        account: AccountId(2),
        child: ChildId(10),
    });
    println!(
        "Eve wrongly recorded for Charlie: authorisation={}",
        child_authorisation::accepts(&state, &request, &approval)
    );
}

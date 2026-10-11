//! Regression tests for acceptance and external-record boundaries.
use collection_types::*;

struct Fixture {
    state: SchoolState,
    request: Request,
    approval: Approval,
}

fn fixture() -> Fixture {
    Fixture {
        state: SchoolState {
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
        },
        request: Request {
            child: ChildId(10),
            collector: CollectorId(2),
            day: Day(42),
        },
        approval: Approval {
            approver: AccountId(2),
            child: ChildId(10),
            collector: CollectorId(2),
            day: Day(42),
        },
    }
}

#[test]
fn legitimate_other_parent_exposes_missing_relationship() {
    let Fixture {
        state,
        request,
        approval,
    } = fixture();
    assert!(collection_details::accepts(&state, &request, &approval));
    assert!(!child_authorisation::accepts(&state, &request, &approval));
}

#[test]
fn incorrect_records_allow_the_same_request() {
    let Fixture {
        mut state,
        request,
        approval,
    } = fixture();
    state.recorded_authorisations.push(RecordedAuthorisation {
        account: AccountId(2),
        child: ChildId(10),
    });
    assert!(child_authorisation::accepts(&state, &request, &approval));
    // Actual school permission remains Alice–Charlie and Eve–another child.
    let actual = [
        RecordedAuthorisation {
            account: AccountId(1),
            child: ChildId(10),
        },
        RecordedAuthorisation {
            account: AccountId(2),
            child: ChildId(20),
        },
    ];
    assert!(!actual.contains(&RecordedAuthorisation {
        account: approval.approver,
        child: request.child
    }));
}

#[test]
fn legitimate_authorised_parent_is_accepted() {
    let Fixture {
        mut state,
        request,
        mut approval,
    } = fixture();
    state.signed_in_parents.push(AccountId(1));
    approval.approver = AccountId(1);
    assert!(child_authorisation::accepts(&state, &request, &approval));
}

#[test]
fn each_detail_is_required_even_with_recorded_authority() {
    for changed in 0..5 {
        let Fixture {
            mut state,
            mut request,
            mut approval,
        } = fixture();
        state.recorded_authorisations.push(RecordedAuthorisation {
            account: approval.approver,
            child: request.child,
        });
        match changed {
            0 => state.signed_in_parents.clear(),
            1 => approval.child = ChildId(99),
            2 => approval.collector = CollectorId(99),
            3 => approval.day = Day(99),
            _ => {
                request.day = Day(99);
                approval.day = Day(99);
            }
        }
        assert!(!collection_details::accepts(&state, &request, &approval));
        assert!(!child_authorisation::accepts(&state, &request, &approval));
    }
}

#[test]
fn another_signed_in_parent_does_not_authenticate_the_approver() {
    let Fixture {
        mut state,
        request,
        approval,
    } = fixture();
    state.signed_in_parents = vec![AccountId(1)];
    state.recorded_authorisations.push(RecordedAuthorisation {
        account: approval.approver,
        child: request.child,
    });
    assert!(!collection_details::accepts(&state, &request, &approval));
    assert!(!child_authorisation::accepts(&state, &request, &approval));
}

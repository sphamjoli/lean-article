import Collection.Rules
namespace Collection

def actual : ActualAuthority := fun account child =>
  (account = 1 ∧ child = 10) ∨ (account = 2 ∧ child = 20)

def school : SchoolState := ⟨[2], [(1, 10), (2, 20)], 42⟩
def request : Request := ⟨10, 2, 42⟩
def eveApproval : Approval := ⟨2, 10, 2, 42⟩
def badRecords : SchoolState := { school with recordedAuthorisations := [(1, 10), (2, 20), (2, 10)] }

theorem eve_passes_details : acceptsDetails school request eveApproval = true := by decide

theorem eve_violates_requirement : ¬ Requirement actual school request eveApproval := by
  simp [Requirement, Details, actual, school, request, eveApproval]

theorem eve_rejected_by_authorisation : acceptsAuthorised school request eveApproval = false := by decide

theorem good_records_faithful : RecordsFaithful school actual := by
  intro account child recorded
  simp [school] at recorded
  simpa [actual] using recorded

theorem eve_passes_bad_records : acceptsAuthorised badRecords request eveApproval = true := by decide

theorem eve_still_violates_requirement : ¬ Requirement actual badRecords request eveApproval := by
  simp [Requirement, Details, actual, badRecords, school, request, eveApproval]

theorem bad_records_not_faithful : ¬ RecordsFaithful badRecords actual := by
  intro faithful
  have permission := faithful 2 10 (by decide)
  simp [actual] at permission

def aliceSchool : SchoolState := { school with signedInParents := [1] }
def aliceApproval : Approval := { eveApproval with approver := 1 }

theorem alice_accepted : acceptsAuthorised aliceSchool request aliceApproval = true := by decide

theorem alice_meets_requirement : Requirement actual aliceSchool request aliceApproval := by
  apply authorised_meets_requirement aliceSchool request aliceApproval actual alice_accepted
  exact good_records_faithful

end Collection

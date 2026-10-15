namespace Collection

-- IDs are natural numbers; Rust IDs embed as naturals without arithmetic.
structure SchoolState where
  signedInParents : List Nat
  recordedAuthorisations : List (Nat × Nat)
  today : Nat

structure Request where
  child : Nat
  collector : Nat
  day : Nat

structure Approval where
  approver : Nat
  child : Nat
  collector : Nat
  day : Nat

def acceptsDetails (s : SchoolState) (r : Request) (a : Approval) : Bool :=
  s.signedInParents.contains a.approver &&
  (a.child == r.child) && (a.collector == r.collector) &&
  (a.day == r.day) && (r.day == s.today)

def Details (s : SchoolState) (r : Request) (a : Approval) : Prop :=
  a.approver ∈ s.signedInParents ∧ a.child = r.child ∧
  a.collector = r.collector ∧ a.day = r.day ∧ r.day = s.today

theorem details_characterisation (s : SchoolState) (r : Request) (a : Approval) :
    acceptsDetails s r a = true ↔ Details s r a := by
  simp [acceptsDetails, Details, and_assoc]

def acceptsAuthorised (s : SchoolState) (r : Request) (a : Approval) : Bool :=
  acceptsDetails s r a && s.recordedAuthorisations.contains (a.approver, r.child)

def ActualAuthority := Nat → Nat → Prop

def SuppliedInputRequirement (actual : ActualAuthority) (s : SchoolState) (r : Request)
    (a : Approval) : Prop :=
  Details s r a ∧ actual a.approver r.child

def RecordsFaithful (s : SchoolState) (actual : ActualAuthority) : Prop :=
  ∀ account child, (account, child) ∈ s.recordedAuthorisations → actual account child

theorem authorised_characterisation (s : SchoolState) (r : Request) (a : Approval) :
    acceptsAuthorised s r a = true ↔
      Details s r a ∧ (a.approver, r.child) ∈ s.recordedAuthorisations := by
  simp [acceptsAuthorised, details_characterisation]

theorem authorised_meets_requirement (s : SchoolState) (r : Request) (a : Approval)
    (actual : ActualAuthority) (accepted : acceptsAuthorised s r a = true)
    (faithful : RecordsFaithful s actual) : SuppliedInputRequirement actual s r a := by
  obtain ⟨details, recorded⟩ := (authorised_characterisation s r a).mp accepted
  exact ⟨details, faithful a.approver r.child recorded⟩

-- Completeness is a separate assumption from the absence of false permissions.
def RecordsComplete (s : SchoolState) (actual : ActualAuthority) : Prop :=
  ∀ account child, actual account child → (account, child) ∈ s.recordedAuthorisations

theorem supplied_requirement_accepted (s : SchoolState) (r : Request) (a : Approval)
    (actual : ActualAuthority) (complete : RecordsComplete s actual)
    (required : SuppliedInputRequirement actual s r a) : acceptsAuthorised s r a = true := by
  exact (authorised_characterisation s r a).mpr
    ⟨required.1, complete a.approver r.child required.2⟩

-- A teaching wrapper outside the acceptance API; this is not authentication.
structure Submission where
  submitter : Nat
  approval : Approval

def acceptsSubmission (s : SchoolState) (r : Request) (submission : Submission) : Bool :=
  acceptsAuthorised s r submission.approval

theorem submission_ignores_submitter (s : SchoolState) (r : Request) (a : Approval)
    (first second : Nat) :
    acceptsSubmission s r ⟨first, a⟩ = acceptsSubmission s r ⟨second, a⟩ := rfl

end Collection

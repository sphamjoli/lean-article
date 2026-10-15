import Collection
import CollectionAudit

namespace Unlisted
axiom bogus : False
theorem one_eq_two : 1 = 2 := False.elim bogus
end Unlisted

#audit_collection

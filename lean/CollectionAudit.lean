import Lean
import Lean.Compiler.ImplementedByAttr
import Lean.Compiler.IR.CompilerM
open Lean Elab Command

private def projectModule (name : Name) : Bool :=
  name == `Collection || (`Collection).isPrefixOf name

elab "#audit_collection" : command => do
  let env ← getEnv
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  let mut count := 0
  let mut failed := false
  for (name, info) in env.constants.toList do
    let owned := match env.getModuleIdxFor? name with
      | some index => projectModule env.header.moduleNames[index.toNat]!
      | none => true
    if owned then
      count := count + 1
      if let .axiomInfo _ := info then
        let compilerEntry :=
          (IR.findEnvDecl env name).isSome
        let sourceDeclaration := (← findDeclarationRangesCore? name).isSome
        unless info.isUnsafe && compilerEntry && !sourceDeclaration do
          logError m!"Forbidden axiom dependency: explicit project axiom {name}"
          failed := true
          continue
      if info.isUnsafe then
        logInfo m!"Execution-only unsafe declaration for review: {name}"
        continue
      let axioms ← collectAxioms name
      for dependency in axioms do
        unless allowed.contains dependency do
          logError m!"Forbidden axiom dependency: {name} uses {dependency}"
          failed := true
      if (match info with | .opaqueInfo _ => true | _ => false) ||
          (externAttr.getParam? env name).isSome ||
          (Lean.Compiler.implementedByAttr.getParam? env name).isSome then
        logInfo m!"Execution boundary for review: {name}"
  if count == 0 then
    throwError "No project declarations audited"
  if failed then
    throwError "Project axiom audit failed"
  logInfo m!"Project axiom audit passed: {count} declarations"

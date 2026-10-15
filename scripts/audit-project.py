"""Build and audit every Collection module, including unreferenced modules."""
from pathlib import Path
import subprocess
import tempfile

modules = ['Collection'] + [
    '.'.join(path.with_suffix('').parts)
    for path in sorted(Path('Collection').rglob('*.lean'))
]
subprocess.run(['lake', 'build', 'CollectionAudit', *('+' + name for name in modules)], check=True)
with tempfile.NamedTemporaryFile(mode='w', suffix='.lean', dir='.', delete=False) as driver:
    path = Path(driver.name)
    driver.write('\n'.join('import ' + name for name in modules))
    driver.write('\nimport CollectionAudit\n#audit_collection\n')
try:
    subprocess.run(['lake', 'env', 'lean', '-DwarningAsError=true', str(path)], check=True)
finally:
    path.unlink()

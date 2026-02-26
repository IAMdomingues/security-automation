<#
.SYNOPSIS
	Este Script tiene objetivo identificar los usuarios que están inactivos en Microsoft Entra ID (antiguo Azure AD).

.Descripción
	Este script se va a conectar a Microsoft Graoh y generar un reporte de usuarios que no han iniciado sesión en los últimos 30 días.
	Proceso ese fundamental para el Gobierno de Identidades (IGA) y seguridad.

.Author
	Sarah Domingues (@IAMdomingues)

.Date
	2026-02-26
#>

# 1. Definir el umbral de inactividad
$daysInactive = 30
$thresholdDate = (Get-Date).AddDays(-$daysInactive)

Write-Host "Iniciando auditoría de usuarios inactivos (más de $daysInactive días)…" -ForegroundColor Cyan

#2. Conectar a Microsoft Graph
# Conenect-MGraph - scopes "User.Read.all", "AuditLog.Read.All"

#3. Obtener todos los usuarios ocn su última actividad de inicio de sesión
# Nota: La propiedad signInActivity requiere licencia Azure AD Premium P1/P2
$allUsers = Get-MgUser -All - Property "displayName", "userPrincipalName", "signInActivity", "accountEnabled"

$inactiveUsers = $allUseres | Where-Object {
	$_.signInActivity.lastSignInDateTime - lt $thresholdDate -and
	$_.accountEnabled -eq $true
}

# 4. Mostrar resultados en consola
if ($inactiveUsers) {
    Write-Host "Se encontraron $($inactiveUsers.Count) usuarios activos pero inactivos en acceso." -ForegroundColor Yellow
    $inactiveUsers | Select-Object displayName, userPrincipalName, @{N="LastSignIn"; E={$_.signInActivity.lastSignInDateTime}} | Format-Table
} else {
    Write-Host "No se encontraron usuarios inactivos en el periodo seleccionado." -ForegroundColor Green
}

# 5. Exportar reporte a CSV para auditoría
# $inactiveUsers | Export-Csv -Path "./Reporte_Inactivos_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

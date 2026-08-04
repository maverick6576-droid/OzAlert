#!/usr/bin/env bash
# Script automatizado de despliegue para Google Cloud Shell
# Proyecto: OzVisa Alert ($0 Coste - Free Tier)

set -e

echo "========================================================"
echo "🚀 Desplegando OzVisa Alert en Google Cloud Functions"
echo "========================================================"

# 1. Verificar y establecer proyecto (por defecto ozvisa-alert-prod si está disponible)
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID="ozvisa-alert-prod"
  echo "ℹ️ Configurando proyecto de Google Cloud: $PROJECT_ID"
  gcloud config set project "$PROJECT_ID"
else
  echo "✅ Usando el proyecto activo en Cloud Shell: $PROJECT_ID"
fi

echo ""
echo "📦 1/3 Habilitando APIs necesarias (o verificando estado activo)..."
gcloud services enable \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  cloudscheduler.googleapis.com \
  run.googleapis.com \
  --quiet || echo "ℹ️ Las APIs ya están habilitadas o hay un límite temporal de comprobación. Continuando con el despliegue..."

echo ""
echo "☁️  2/3 Desplegando Google Cloud Function (Python 3.11 - Europa europe-west1 - Coste $0)..."
gcloud functions deploy check-visa-status \
  --gen2 \
  --runtime=python311 \
  --region=europe-west1 \
  --source=. \
  --entry-point=check_visa_status \
  --trigger-http \
  --allow-unauthenticated \
  --memory=256MB \
  --max-instances=1 \
  --timeout=60s \
  --quiet

echo ""
echo "⏰ 3/3 Configurando Cloud Scheduler para ejecutar el radar cada 2 minutos en Europa..."
SERVICE_URL=$(gcloud functions describe check-visa-status --region=europe-west1 --format="value(serviceConfig.uri)")
echo "🔗 URL del servicio desplegado: $SERVICE_URL"

# Intentar actualizar o crear el trabajo programado
if gcloud scheduler jobs describe ozvisa-radar-job --location=europe-west1 &>/dev/null; then
  echo "🔄 Actualizando trabajo programado existente..."
  gcloud scheduler jobs update http ozvisa-radar-job \
    --location=europe-west1 \
    --schedule="*/2 * * * *" \
    --uri="${SERVICE_URL}" \
    --http-method=GET \
    --quiet
else
  echo "🆕 Creando nuevo trabajo programado cada 2 minutos en europe-west1..."
  gcloud scheduler jobs create http ozvisa-radar-job \
    --location=europe-west1 \
    --schedule="*/2 * * * *" \
    --uri="${SERVICE_URL}" \
    --http-method=GET \
    --description="Radar de Visas Work & Holiday Australia (Cada 2m)" \
    --quiet
fi

echo ""
echo "========================================================"
echo "✅ ¡DESPLIEGUE EXITOSO DE OZVISA ALERT!"
echo "📍 Tu radar está corriendo en el servidor con coste $0."
echo "========================================================"

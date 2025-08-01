from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.payment import Payment
from app.schemas.payment import PaymentCreate, PaymentResponse, PaymentUpdate
from app.services.payment_service import PaymentService

router = APIRouter()

@router.get("/", response_model=List[PaymentResponse])
def get_payments(db: Session = Depends(get_db)):
    service = PaymentService(db)
    return service.get_all_payments()

@router.get("/{payment_id}", response_model=PaymentResponse)
def get_payment(payment_id: int, db: Session = Depends(get_db)):
    service = PaymentService(db)
    payment = service.get_payment_by_id(payment_id)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    return payment

@router.post("/", response_model=PaymentResponse)
def create_payment(payment: PaymentCreate, db: Session = Depends(get_db)):
    service = PaymentService(db)
    return service.create_payment(payment)

@router.put("/{payment_id}", response_model=PaymentResponse)
def update_payment(payment_id: int, payment_update: PaymentUpdate, db: Session = Depends(get_db)):
    service = PaymentService(db)
    payment = service.update_payment(payment_id, payment_update)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    return payment

@router.get("/order/{order_id}", response_model=List[PaymentResponse])
def get_payments_by_order(order_id: int, db: Session = Depends(get_db)):
    service = PaymentService(db)
    return service.get_payments_by_order_id(order_id)

@router.get("/user/{user_id}", response_model=List[PaymentResponse])
def get_payments_by_user(user_id: int, db: Session = Depends(get_db)):
    service = PaymentService(db)
    return service.get_payments_by_user_id(user_id)
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.payment import PaymentStatus

class PaymentBase(BaseModel):
    order_id: int
    user_id: int
    amount: float
    currency: str = "USD"
    payment_method: str

class PaymentCreate(PaymentBase):
    pass

class PaymentUpdate(BaseModel):
    status: Optional[PaymentStatus] = None
    transaction_id: Optional[str] = None

class PaymentResponse(PaymentBase):
    id: int
    status: PaymentStatus
    transaction_id: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
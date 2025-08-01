from sqlalchemy.orm import Session
from app.models.payment import Payment, PaymentStatus
from app.schemas.payment import PaymentCreate, PaymentUpdate
import uuid

class PaymentService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_payments(self):
        return self.db.query(Payment).all()

    def get_payment_by_id(self, payment_id: int):
        return self.db.query(Payment).filter(Payment.id == payment_id).first()

    def create_payment(self, payment: PaymentCreate):
        db_payment = Payment(
            order_id=payment.order_id,
            user_id=payment.user_id,
            amount=payment.amount,
            currency=payment.currency,
            payment_method=payment.payment_method,
            transaction_id=str(uuid.uuid4())
        )
        self.db.add(db_payment)
        self.db.commit()
        self.db.refresh(db_payment)
        return db_payment

    def update_payment(self, payment_id: int, payment_update: PaymentUpdate):
        payment = self.get_payment_by_id(payment_id)
        if payment:
            if payment_update.status:
                payment.status = payment_update.status
            if payment_update.transaction_id:
                payment.transaction_id = payment_update.transaction_id
            self.db.commit()
            self.db.refresh(payment)
        return payment

    def get_payments_by_order_id(self, order_id: int):
        return self.db.query(Payment).filter(Payment.order_id == order_id).all()

    def get_payments_by_user_id(self, user_id: int):
        return self.db.query(Payment).filter(Payment.user_id == user_id).all()
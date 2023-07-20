import React from "react";

type ModalProps = {
    isOpen: boolean;
    onClose: () => void;
    children: React.ReactNode;
};

const Modal: React.FC<ModalProps> = ({ isOpen, onClose, children }) => {
    if (!isOpen) return null;

    const handleClose = (event: React.MouseEvent<HTMLButtonElement> | any) => {
        if (event.target?.id === "wrapper") onClose();
    };

    return (
        <div
            className="fixed inset-0 bg-black bg-opacity-25 backdrop-blur-sm flex justify-center items-center"
            id="wrapper"
            onClick={handleClose}
        >
            <div className="md:w-[600px] w-[90%] mx-auto flex flex-col">
                <button
                    className="text-white text-xl place-self-end"
                    onClick={() => onClose()}
                >
                    X
                </button>
                <div className="bg-white p-2 rounded">{children}</div>
            </div>
        </div>
    );
};

export default Modal;

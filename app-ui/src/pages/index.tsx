import Modal from "@/components/Modal";
import React, { useState } from "react";

const Index: React.FC = () => {
    const [modalOpen, setModalOpen] = useState(false);

    const openModal = () => {
        setModalOpen(true);
    };

    const closeModal = () => {
        setModalOpen(false);
    };

    return <div>Teste</div>;
};

export default Index;
